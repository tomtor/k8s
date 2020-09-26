PORT=30779
HOST=localhost
PGU=tom
DB=bgt

for f in *.gml # .gz
do
  TAB=$(echo "$f" | sed -e "s/bgt_//" -e "s/\\.gml.*//")

  echo $(date) start clustering: $TAB

  echo "CREATE INDEX ${TAB}_wkb_geometry_hash_idx ON public.$TAB (ST_GeoHash(ST_Transform(wkb_geometry,4326)));" | psql -U $PGU -h $HOST -p $PORT $DB

  echo "CLUSTER VERBOSE public.$TAB USING ${TAB}_wkb_geometry_hash_idx;" | psql -U $PGU -h $HOST -p $PORT $DB

  echo "analyze verbose public.$TAB;" | psql -U $PGU -h $HOST -p $PORT $DB

  echo $(date) end clustering of $TAB
  echo

done

exit 0
