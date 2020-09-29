PORT=30779
HOST=localhost
PGU=tom
DB=bgt

for f in $(echo "select tablename from pg_tables where tablename like 'bag_%pand%'" | \
    psql -U $PGU -h $HOST -p $PORT -d $DB -t)
do
  TAB=$f
  TABSHORT=$(echo $TAB | sed 's/bag_extract_deelbestand__antwoord_producten_lvc_//')

  echo $(date) start clustering: $TAB

  echo "CREATE INDEX ${TABSHORT}_wkb_geometry_hash_idx ON public.$TAB (ST_GeoHash(ST_Transform(pandgeometrie,4326)));" | psql -U $PGU -h $HOST -p $PORT $DB

  echo "CLUSTER VERBOSE public.$TAB USING ${TABSHORT}_wkb_geometry_hash_idx;" | psql -U $PGU -h $HOST -p $PORT $DB

  echo "analyze verbose public.$TAB;" | psql -U $PGU -h $HOST -p $PORT $DB

  echo $(date) end clustering of $TAB
  echo

done

exit 0
