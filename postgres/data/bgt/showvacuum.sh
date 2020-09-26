PORT=30779
HOST=localhost
PGU=postgresadmin
DB=bgt


while :
do

psql -P pager=off -U $PGU -h $HOST -p $PORT -t -c "select phase,heap_blks_scanned,heap_blks_total,relname,index_vacuum_count,heap_blks_scanned::float / heap_blks_total * 100 as scanned_perc_done, heap_blks_vacuumed::float / heap_blks_total * 100 as vacuumed_perc_done from pg_stat_progress_vacuum,pg_class where pg_stat_progress_vacuum.relid = pg_class.oid;" $DB

sleep 60

done
