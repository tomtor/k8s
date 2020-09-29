PORT=30779
HOST=localhost
PGU=tom
DB=top50

SRC=TOP50NL_GML_Filechunks_september_2020/Top50NL_GML_Filechuncks

dropdb -U $PGU -h $HOST -p $PORT $DB
createdb -U $PGU -h $HOST -p $PORT $DB
echo "create extension postgis;" | psql -U postgresadmin -h $HOST -p $PORT $DB

for f in $SRC/*.gml
do
  TAB=$(echo "$f" | sed -e "s/bgt_//" -e "s/\\.gml.*//")
  echo $TAB starts at $(date)

  ogr2ogr -progress -f "PostgreSQL" -a_srs EPSG:28992 -nlt CONVERT_TO_LINEAR -lco SPATIAL_INDEX=GIST -lco DIM=2 PG:"dbname=$DB host=$HOST port=$PORT" "$f"

  echo $TAB ends at $(date)

done

rm -rf $SRC

exit 0
