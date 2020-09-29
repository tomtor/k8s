PORT=30779
HOST=localhost
PGU=tom
DB=bgt

echo "select 'drop table '||tablename||' cascade;' from pg_tables where tablename like 'bag_%'" | \
    psql -U $PGU -h $HOST -p $PORT -d $DB -t | \
    psql -U $PGU -h $HOST -p $PORT -d $DB

for f in *.xml
do
  TAB=$(echo "$f" | sed -e "s/9999PND//" -e "s/\\.xml.*//")
  echo $TAB starts at $(date)

  ogr2ogr -progress -f "PostgreSQL" -a_srs EPSG:28992 -nlt CONVERT_TO_LINEAR -lco SPATIAL_INDEX=GIST -lco DIM=2 PG:"dbname=$DB host=$HOST port=$PORT" GMLAS:"$f"

  echo $TAB ends at $(date)

done

echo "select count(*) from bag_extract_deelbestand__antwoord_producten_lvc_product_pand;" | psql -U $PGU -h $HOST -p $PORT $DB

echo "delete from bag_extract_deelbestand__antwoord_producten_lvc_product_pand where tijdvakgeldigheid_einddatumtijdvakgeldigheid IS NOT NULL or aanduidingrecordinactief = 'J' or pandstatus = 'Pand gesloopt';" | psql -U $PGU -h $HOST -p $PORT $DB

echo "delete from bag_extract_deelbestand__antwoord_producten_lvc_product_pand where not st_isvalid(pandgeometrie);" | psql -U $PGU -h $HOST -p $PORT $DB

psql -U $PGU -h $HOST -p $PORT $DB < diff-view.sql
