PORT=30779
HOST=localhost
PGU=tom
DB=brk

for f in dkk*.gml # .gz
do
  TAB=$(echo "$f" | sed -e "s/bgt_//" -e "s/\\.gml.*//")
  echo $TAB starts at $(date)

  ogr2ogr -progress -f "PostgreSQL" -overwrite -a_srs EPSG:28992 -nlt CONVERT_TO_LINEAR -lco SPATIAL_INDEX=GIST -lco DIM=2 PG:"dbname=$DB host=$HOST port=$PORT" "$f"

  #if [ "$f" = "dkk_perceel.gml" ]; then
    #echo "CREATE INDEX ${TAB}_multi ON perceel USING gist (begrenzingPerceel,plaatscoordinaten);" | \
        #psql -U $PGU -h $HOST -p $PORT $DB
    #echo "CREATE INDEX ${TAB}_punt ON perceel USING gist (plaatscoordinaten);" | \
        #psql -U $PGU -h $HOST -p $PORT $DB
  #fi

  echo $TAB ends at $(date)

done

exit 0
