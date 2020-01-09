from flask import Flask, flash, request, redirect, url_for, send_from_directory
from werkzeug.utils import secure_filename
from redis import Redis, RedisError
from waitress import serve

import os
import sys
import socket

import psycopg2
from psycopg2 import pool

threaded_postgreSQL_pool = None

def db_connect():
    global threaded_postgreSQL_pool
    if threaded_postgreSQL_pool:
        threaded_postgreSQL_pool.closeall()
    print("Connecting", file=sys.stderr)
    threaded_postgreSQL_pool = psycopg2.pool.ThreadedConnectionPool(5, 20,
                                  user="tom",
                                  password=os.getenv("PGPASS"),
                                  host=os.getenv("PGHOST", "localhost"),
                                  sslmode='require',
                                  port=os.getenv("PGPORT", "5432"),
                                  database="tom")

db_connect()

def query():
    connection  = threaded_postgreSQL_pool.getconn()
    cursor = connection.cursor()
    cursor.execute("select t, d from (select t, t - lag(t) over() as d \
        from hartbeat) as ss where \
        extract(hour from d) * 3600 + extract(minute from d) * 60 + extract(seconds from d) > 65 \
        order by t desc limit 10;")
    return connection, cursor


def get_delays():
    try:
        connection, cursor = query()
    except:
        db_connect()
        connection, cursor = query()

    d = cursor.fetchall()
    if d:
        result = ""
        for r in d:
            result += (str(r[0]) + ' ' + str(r[1]) + '<br/>\n')
    else:
        result = "No delays"
    cursor.close()
    connection.commit()
    threaded_postgreSQL_pool.putconn(connection)
    return result


redis_host = os.getenv("REDIS", "redis-master")
redis_password = os.getenv("REDIS_PASSWORD")

my_port = int(os.getenv("PORT", "80"))

if my_port == 8888:
    UPLOAD_FOLDER = '/tmp'
else:
    UPLOAD_FOLDER = '/data/archi'
print("Serving from:", UPLOAD_FOLDER)

ALLOWED_EXTENSIONS = {'archimate' }

# Connect to Redis
redis = Redis(host=redis_host, password=redis_password, db=0,
              socket_connect_timeout=2, socket_timeout=2)

app = Flask(__name__, static_url_path="/", static_folder='/data/public')
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/public/<path:path>')
def send_js(path):
    print(path) # , app.static_url_path, app.static_folder)
    return send_from_directory(app.static_folder, path)

@app.route("/status")
def status():
    try:
        visits = redis.incr("counter")
    except RedisError:
        visits = "<i>cannot connect to Redis, counter disabled</i>"

    html = "<h3>Hello {name}!</h3>" \
           "<b>Hostname:</b> {hostname}<br/>" \
           "<b>Visits:</b> {visits}" \
           "<p>" \
           + get_delays() \
           + "</p>"
    return html.format(name=os.getenv("NAME", "world"), hostname=socket.gethostname(), visits=visits)

@app.route("/")
def hello():
    return "Nothing here..."

import xml.etree.cElementTree as ET
import urllib.request
import uuid


def update_archi(filename):
    response = urllib.request.urlopen(
        'https://raw.githubusercontent.com/tomtor/archi-test/master/Kadaster-Repository.archimate')
    new_repo = response.read()
    new_repo = ET.fromstring(new_repo)

    data = ET.parse(UPLOAD_FOLDER + "/" + filename)
    root = data.getroot()
    root.attrib["xmlns:archimate"] = "http://www.archimatetool.com/archimate"

    old_repo = root.find(".//folder[@name='Kadaster Repository']")
    if old_repo:
        root.remove(old_repo)
    else:
        print("no old repo")
    root.insert(0, new_repo.find(".//folder[@name='Kadaster Repository']"))

    for e in root.findall(".//child[@archimateElement]"):
        aelem = e.get("archimateElement")
        if not root.findall(".//element[@id='" + aelem + "']"):
            print("Removed: ", aelem)
            old = root.find(".//folder[@name='OLD-Repo']")
            if not old:
                print("Create OLD-Repo folder")
                old = ET.SubElement(root, "folder")
                old.attrib["name"] = "OLD-Repo"
                old.attrib["id"] = str(uuid.uuid4())
                old.attrib["type"] = "other"
                root.append(old)
            aelem = old_repo.find(".//element[@id='" + aelem + "']")
            old.append(aelem)

    tree = ET.ElementTree(root)

    tree.write(UPLOAD_FOLDER + "/kad." + filename)
    return redirect(url_for('uploaded_file', filename="kad." + filename))

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'],
                               filename)

@app.route('/archi', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        # check if the post request has the file part
        if 'file' not in request.files:
            flash('No file part')
            return redirect(request.url)
        file = request.files['file']
        # if user does not select file, browser also
        # submit an empty part without filename
        if file.filename == '':
            flash('No selected file')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            return update_archi(filename)
    return '''
    <!doctype html>
    <title>Add Kadaster Repository to Archi File</title>
    <h1>Upload existing .archimate File</h1>
    <p>In return you will receive a new .archimate with an (updated) Kadaster
    Repository and <tt>kad.</tt> prefix.
    </p>
    <form method=post enctype=multipart/form-data>
      <input type=file name=file>
      <input type=submit value=Upload>
    </form>
    <p>
    Questions/suggestions/donations (&euro;40) to: <A
    HREF="mailto:tom.vijlbrief@kadaster.nl">tom.vijlbrief@kadaster.nl</A>
    <p>
    '''

if __name__ == "__main__":
    serve(app, host='0.0.0.0', port=my_port)
