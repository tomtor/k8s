from flask import Flask
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
    connection, cursor = query()

    d = cursor.fetchall()
    if d:
        result = ""
        for r in d:
            result += (str(r[0]) + ' ' + str(r[1]) + '<br/>\n')
    else:
        result = "No delays"
    cursor.close()
    threaded_postgreSQL_pool.putconn(connection)
    return result


redis_host = os.getenv("REDIS", "redis-master")
redis_password = os.getenv("REDIS_PASSWORD")

my_port = int(os.getenv("PORT", "80"))

# Connect to Redis
redis = Redis(host=redis_host, password=redis_password, db=0,
              socket_connect_timeout=2, socket_timeout=2)

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
    serve(app, host='0.0.0.0', port=my_port)
    #app.run(host='0.0.0.0', port=my_port)
    # print(get_delays())
