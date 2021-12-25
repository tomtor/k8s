export PGHOST=localhost
export PGPORT=30779

#echo 'drop table pand10; select gml_id, ST_GeometryN(pand.wkb_geometry,1) as geometry, st_area(ST_GeometryN(pand.wkb_geometry,1)) as area into pand10 from pand where st_intersects(st_transform(pand.wkb_geometry,4326), ST_MakeEnvelope(5, 52, 5.1, 52.1, 4326))' | psql -A -t bgt
echo 'CREATE INDEX IF NOT EXISTS pand10idx ON public.pand10 USING gist (geometry) TABLESPACE pg_default;' | psql -A -t bgt

echo 'select count(*) from pand10 where area > 10000;' | psql -A -t bgt

echo 'select count(a.geometry) from pand10 as a, pand10 as b where a.gml_id != b.gml_id and st_area(a.geometry) > 10000 and st_distance(a.geometry,b.geometry) < 1' | psql -A -t bgt

curl "http://localhost:3030/ds?query=$(jq -sRr @uri query.rq)" | fgrep float | wc
