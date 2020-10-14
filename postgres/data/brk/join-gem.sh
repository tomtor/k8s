PORT=30779
HOST=localhost
PGU=tom
DB=brk


psql -c "
DROP SEQUENCE public.kadgemeentegrens_ogc_fid_seq;
CREATE SEQUENCE public.kadgemeentegrens_ogc_fid_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;
DROP TABLE kadgemeentegrens;
" -t -U $PGU -h $HOST -p $PORT $DB

psql -c "
select nextval('kadgemeentegrens_ogc_fid_seq'::regclass) as ogc_fid,
       st_multi(st_union(begrenzingperceel)) as grens,
       kadastralegemeente
into kadgemeentegrens from perceel
-- where kadastralegemeente LIKE 'B%'
group by kadastralegemeente;
" -t -U $PGU -h $HOST -p $PORT $DB

psql -c "
ALTER TABLE public.kadgemeentegrens
    ADD PRIMARY KEY (ogc_fid);
ALTER TABLE kadgemeentegrens ALTER COLUMN grens type geometry(MultiPolygon, 28992);
CREATE INDEX kadgemeentegrens_grens_geom_idx
    ON public.kadgemeentegrens USING gist
    (grens);
" -t -U $PGU -h $HOST -p $PORT $DB

