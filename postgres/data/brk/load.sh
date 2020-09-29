PORT=30779
HOST=localhost
PGU=tom
DB=brk

for f in dkk*.gml
do
  TAB=$(echo "$f" | sed -e "s/bgt_//" -e "s/\\.gml.*//")
  echo $TAB starts at $(date)

  ogr2ogr -progress -f "PostgreSQL" -overwrite -a_srs EPSG:28992 -nlt CONVERT_TO_LINEAR -lco SPATIAL_INDEX=GIST -lco DIM=2 PG:"dbname=$DB host=$HOST port=$PORT" "$f"

  echo $TAB ends at $(date)
done

ogr2ogr -progress -f "gpkg" -a_srs EPSG:28992 brk.gpkg PG:"dbname=$DB host=$HOST port=$PORT"

zip brk.zip brk.gpkg
rm brk.gpkg
mv brk.zip /data/pythonapp/public/

exit 0
