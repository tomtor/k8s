PORT=30779
HOST=localhost
PGU=tom
DB=bgt

echo "select count(*) from gerelateerdeadressen;" | psql -U $PGU -h $HOST -p $PORT $DB
echo "delete from gerelateerdeadressen where nevenadres_identificatie IS NULL;" | psql -U $PGU -h $HOST -p $PORT $DB

for t in bag_pand bag_woonplaats bag_openbareruimte bag_nummeraanduiding bag_verblijfsobject bag_standplaats bag_ligplaats
do
  echo Clean $t

  echo "select count(*) from $t;" | psql -U $PGU -h $HOST -p $PORT $DB

  echo "delete from $t where tijdvakgeldigheid_einddatumtijdvakgeldigheid IS NOT NULL or aanduidingrecordinactief = 'J' ;" | psql -U $PGU -h $HOST -p $PORT $DB

done
