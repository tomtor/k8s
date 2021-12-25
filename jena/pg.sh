export PGHOST=localhost
export PGPORT=30779

echo 'select count(*) from perceel10;' | psql -A -t brk

echo '
select count(distinct perceel10.gml_id) from perceel10, pand10 where st_intersects(perceel10.latlong, pand10.latlong)' | time psql -A -t brk
echo '
select count(perceel10.gml_id) from perceel10, pand10 where st_intersects(perceel10.latlong, pand10.latlong)' | time psql -A -t brk

echo 'drop table perceel10 cascade' | psql -A -t brk
echo 'drop table pand10 cascade' | psql -A -t brk

echo 'select gml_id, st_transform(begrenzingperceel, 4326) as latlong into perceel10
from perceel where st_intersects(st_transform(begrenzingperceel,4326), ST_MakeEnvelope(5, 52, 5.1, 52.1, 4326))
' | psql -A -t brk

# pg_dump -t pand bgt | psql brk

echo 'select gml_id, st_transform(wkb_geometry, 4326) as latlong into pand10 
from pand where st_intersects(st_transform(pand.wkb_geometry,4326), ST_MakeEnvelope(5, 52, 5.1, 52.1, 4326))
' | psql -A -t brk

echo '
CREATE INDEX IF NOT EXISTS pand10idx
    ON public.pand10 USING gist
    (latlong)
    TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS perceel10idx
    ON public.perceel10 USING gist
    (latlong)
    TABLESPACE pg_default;
' | psql -A -t brk

echo 'select count(*) from perceel10;' | psql -A -t brk

echo '
select count(distinct perceel10.gml_id) from perceel10, pand10 where st_intersects(perceel10.latlong, pand10.latlong)' | time psql -A -t brk
