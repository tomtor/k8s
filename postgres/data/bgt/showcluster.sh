PORT=30779
HOST=localhost
PGU=tom
DB=bgt


while :
do

psql -U $PGU -h $HOST -p $PORT -t -c "select heap_tuples_scanned,reltuples,relname, heap_tuples_scanned / reltuples * 100 as perc_done from pg_stat_progress_cluster,pg_class where pg_stat_progress_cluster.relid = pg_class.oid;" $DB

sleep 60

done
