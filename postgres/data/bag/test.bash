#!/bin/bash

PORT=30779
HOST=localhost
PGU=tom
DB=bagtest

echo "select 'drop table '||schemaname||'.'||tablename||' cascade;' from pg_tables where tablename similar to 'bag_%|%collectie%|%gerelateerde%'" | psql -U $PGU -h $HOST -p $PORT -d $DB -t | psql -U $PGU -h $HOST -p $PORT -d $DB

for f in 9999*000001.xml # 9999*PND*.xml
do
  echo $f starts at $(date)

  ogr2ogr -forceNullable -progress -f "PostgreSQL" -a_srs EPSG:28992 -nlt CONVERT_TO_LINEAR -lco COLUMN_TYPES=nevenadres_identificatie=text -lco SPATIAL_INDEX=GIST -lco DIM=2 PG:"dbname=$DB host=$HOST port=$PORT" GMLAS:"$f"

  echo $f ends at $(date)

done

exit 0

psql -U $PGU -h $HOST -p $PORT $DB << EOF

DROP TABLE bag_extract_deelbestand_lvc;
ALTER TABLE bag_extract_deelbestand__antwoord_producten_lvc_product_pand RENAME TO bag_pand;
ALTER TABLE bag_extract_deelbe_antwoord_producten_lvc_product_woonplaats RENAME TO bag_woonplaats;
ALTER TABLE bag_extract_de_antwoord_producten_lvc_product_openbareruimte RENAME TO bag_openbareruimte;
ALTER TABLE bag_extract__antwoord_producten_lvc_product_nummeraanduiding RENAME TO bag_nummeraanduiding;
ALTER TABLE bag_extract_d_antwoord_producten_lvc_product_verblijfsobject RENAME TO bag_verblijfsobject;
ALTER TABLE bag_extract_deelb_antwoord_producten_lvc_product_standplaats RENAME TO bag_standplaats;
ALTER TABLE bag_extract_deelbes_antwoord_producten_lvc_product_ligplaats RENAME TO bag_ligplaats;
EOF

echo "select count(*) from bag_pand;" | psql -U $PGU -h $HOST -p $PORT $DB

echo "delete from bag_pand where tijdvakgeldigheid_einddatumtijdvakgeldigheid IS NOT NULL or aanduidingrecordinactief = 'J' or pandstatus = 'Pand gesloopt';" | psql -U $PGU -h $HOST -p $PORT $DB

echo "delete from bag_pand where not st_isvalid(pandgeometrie);" | psql -U $PGU -h $HOST -p $PORT $DB

psql -U $PGU -h $HOST -p $PORT $DB < diff-view.sql
