from flask import Flask
from redis import Redis, RedisError
import os
import socket

import psycopg2

def get_delays():
  try:
    connection = psycopg2.connect(user = "tom",
                                  password = os.getenv("PGPASS"),
                                  host = os.getenv("PGHOST", "localhost"), sslmode='require',
                                  port = os.getenv("PGPORT", "5432"), database = "tom")
    cursor = connection.cursor()
    cursor.execute("select t, d from (select t, t - lag(t) over() as d \
        from hartbeat) as ss where \
        extract(minute from d) * 60 + extract(seconds from d) > 65 \
        order by t desc limit 10;")
    d = cursor.fetchall()
    if d:
        result = ""
        for r in d:
            result += (str(r[0]) + ' ' + str(r[1]) + '<br/>\n')
    else:
        result = "No delays"
    return result
  finally:
    if connection:
        cursor.close()
        connection.close()


redis_host = os.getenv("REDIS", "redis-master")
redis_password = os.getenv("REDIS_PASSWORD")

my_port = int(os.getenv("PORT", "80"))

# Connect to Redis
redis = Redis(host=redis_host, password=redis_password, db=0, socket_connect_timeout=2, socket_timeout=2)

app = Flask(__name__)

@app.route("/")
def hello():
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

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=my_port)
    #print(get_delays())
