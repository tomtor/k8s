PORT=30779
HOST=localhost
PGU=tom
DB=brk

HOST=tomgeo.postgres.database.azure.com
PORT=5432
PGU=postgresadmin@tomgeo

#psql -c 'analyze' -t -U $PGU -h $HOST -p $PORT $DB

for N in 100 1000 5000 10000 # 20000 50000 100000 200000
do
  psql -c '\timing' -c "
    drop table if exists q;
    select ST_Buffer('SRID=28992;Point(145000 468000)',5000,$N) as geom into q;
    " \
   -t -U $PGU -h $HOST -p $PORT $DB
  #psql -c 'CREATE INDEX q_geom_idx ON q USING gist (geom);' -t -U $PGU -h $HOST -p $PORT $DB
  #psql -c 'vacuum analyze q' -t -U $PGU -h $HOST -p $PORT $DB
  psql -c 'analyze verbose q' -t -U $PGU -h $HOST -p $PORT $DB

  echo -n "Nr of points: "
  expr 4 \* $N

  Q="SET max_parallel_workers_per_gather = 0;
     drop table if exists rq;
     select perceel.lokaalid,perceel.begrenzingPerceel into rq from perceel right join q on st_intersects(q.geom,begrenzingPerceel);
    "
  psql -c '\timing' -c "$Q" -t -U $PGU -h $HOST -p $PORT $DB

  Q="SET max_parallel_workers_per_gather = 0;
     drop table if exists rq;
     select perceel.lokaalid,perceel.begrenzingPerceel into rq from perceel join (select distinct q.geom from q)t on st_intersects(begrenzingPerceel,t.geom);
    "
  #psql -c '\timing' -c "$Q" -t -U $PGU -h $HOST -p $PORT $DB

  Q="SET max_parallel_workers_per_gather = 0;
     drop table if exists r;
     select perceel.lokaalid,perceel.begrenzingPerceel into r from perceel where st_intersects(begrenzingPerceel, ST_Buffer('SRID=28992;Point(145000 468000)',5000,$N));
    "
  psql -c '\timing' -c "$Q" -t -U $PGU -h $HOST -p $PORT $DB

  echo
done

