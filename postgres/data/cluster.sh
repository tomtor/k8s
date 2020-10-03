PORT=30779
HOST=localhost
PGU=tom
DB=$1

for TAB in $(
  psql -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';" -t -U $PGU -h $HOST -p $PORT $DB
  )
do

  echo $(date) start clustering: $TAB

  echo "CLUSTER VERBOSE public.$TAB USING ${TAB}_wkb_geometry_geom_idx;" | psql -U $PGU -h $HOST -p $PORT $DB

  echo $(date) end clustering of $TAB
  echo

done

exit 0
