#!/bin/sh

psql -h localhost -p 30258 -U tom tom << EOF
  create table hartbeat(id serial primary key, t timestamptz);
EOF

while :
do
  echo "insert into hartbeat(t) values(now());" | psql -h localhost -p 30258 -U tom tom
  sleep 60
done
