PORT=30779
HOST=localhost
PGU=tom
DB=bgt

echo "select 'drop table '||tablename||' cascade;' from pg_tables where tablename like 'bag_%'" | \
    psql -U $PGU -h $HOST -p $PORT -d $DB -t | \
    psql -U $PGU -h $HOST -p $PORT -d $DB
