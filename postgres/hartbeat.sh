#!/bin/sh

echo "create table hartbeat(t timestamp);" | psql -h localhost -p 30258 -U tom tom

while :
do
  echo "insert into hartbeat(t) values(now());" | psql -h localhost -p 30258 -U tom tom
  sleep 60
done
