PORT=30779
HOST=localhost
PGU=tom
DB=bgt

for f in *.gml # .gz
do
  TAB=$(echo "$f" | sed -e "s/bgt_//" -e "s/\\.gml.*//")
  echo $TAB starts at $(date)

  ogr2ogr -progress -f "PostgreSQL" -overwrite -where "objecteindtijd is null and eindregistratie is null" -a_srs EPSG:28992 -nlt CONVERT_TO_LINEAR -lco SPATIAL_INDEX=GIST -lco DIM=2 PG:"dbname=$DB host=$HOST port=$PORT" "$f"

  # echo "ALTER TABLE public.$TAB CLUSTER ON ${TAB}_wkb_geometry_geom_idx;" | psql -U $PGU -h $HOST -p $PORT $DB
  echo $TAB ends at $(date)

done

exit 0

  echo "DROP TABLE $TAB;" | psql -U $PGU -h $HOST -p $PORT $DB

  echo "CREATE INDEX ${TAB}_multi ON public.$TAB USING gist (wkb_geometry);" | \
	psql -U $PGU -h $HOST -p $PORT $DB

    ALTER TABLE public.kunstwerkdeel CLUSTER ON kunstwerkdeel_multi;" | psql -U $PGU -h $HOST -p $PORT $DB
    # (geometrie_multivlak, geometrie_lijn, geometrie_multipunt, geometrie_vlak)
