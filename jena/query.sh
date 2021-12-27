export PGHOST=localhost
export PGPORT=30779

###echo 'drop table pand10; select gml_id, st_transform(ST_GeometryN(pand.wkb_geometry,1),4326) as geometry, pand.wkb_geometry, st_area(ST_GeometryN(pand.wkb_geometry,1)) as area into pand10 from pand where st_intersects(st_transform(pand.wkb_geometry,4326), ST_MakeEnvelope(5, 52, 5.1, 52.1, 4326))' | psql -A -t bgt
#echo 'drop table pand10; select gml_id, st_transform(pand.wkb_geometry,4326) as geometry, pand.wkb_geometry, st_area(pand.wkb_geometry) as area into pand10 from pand where st_intersects(st_transform(pand.wkb_geometry,4326), ST_MakeEnvelope(5, 52, 5.05, 52.05, 4326))' | psql -A -t bgt

echo 'CREATE INDEX IF NOT EXISTS pand10idx ON public.pand10 USING gist (geometry);' | psql -A -t bgt
echo 'CREATE INDEX IF NOT EXISTS pand10wkbidx ON public.pand10 USING gist (wkb_geometry);' | psql -A -t bgt
echo 'vacuum analyze pand10;' | psql -A -t bgt

echo 'select count(*) from pand10;' | psql -A -t bgt
echo 'select count(*) from pand10 where area > 1000;' | psql -A -t bgt

###echo 'select count(*) from pand10 as a, pand10 as b where a.gml_id != b.gml_id and a.area > 1000 and st_distancesphere(a.geometry,b.geometry) < 10' | psql -A -t bgt
echo '\\timing on
select count(a.gml_id) from pand10 as a, pand10 as b where
a.gml_id != b.gml_id and a.area > 1000 and
ST_DWithin(a.wkb_geometry, b.wkb_geometry, 10)
-- and st_distance(a.wkb_geometry,b.wkb_geometry) < 10' | psql -A -t bgt

curl "http://localhost:3030/ds?query=$(jq -sRr @uri query.rq)" | fgrep float | wc
