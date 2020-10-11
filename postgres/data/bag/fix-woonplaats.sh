PORT=30779
HOST=localhost
PGU=tom
DB=bgt

echo "update bag_woonplaats set woonplaatsgeometrie_multisurface = st_multi(st_geomfromgml(woonplaatsgeometrie__surface)) where woonplaatsgeometrie_multisurface is null and woonplaatsgeometrie__surface is not NULL;" | psql -U $PGU -h $HOST -p $PORT $DB

echo "ALTER TABLE public.bag_woonplaats DROP COLUMN woonplaatsgeometrie__surface;" | psql -U $PGU -h $HOST -p $PORT $DB
echo "vacuum full public.bag_woonplaats;" | psql -U $PGU -h $HOST -p $PORT $DB
