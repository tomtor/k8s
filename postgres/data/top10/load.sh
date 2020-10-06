PORT=30779
HOST=localhost
PGU=tom
DB=top10

SRC=TOP10NL_GML_Filechuncks_*/TOP10NL_GML_Filechuncks/

dropdb -U $PGU -h $HOST -p $PORT $DB

echo "CREATE DATABASE $DB TEMPLATE template0 LC_COLLATE 'nl_NL.UTF-8' LC_CTYPE 'nl_NL.UTF-8';" | psql -U $PGU -h $HOST -p $PORT postgres

echo "create extension postgis;" | psql -U postgresadmin -h $HOST -p $PORT $DB

rm -f top10.gfs

awk '
{
     PREV=$0
     if (NR <= 2 || ($0 !~ "top10nl:FeatureCollectionT10NL" && $1 != "<?xml")) print $0
}
END { print PREV}' $SRC/*.gml > top10.gml

for f in top10.gml # $SRC/*.gml
do
  TAB=$(echo "$f" | sed -e "s/bgt_//" -e "s/\\.gml.*//")
  echo $TAB starts at $(date)

  ogr2ogr -progress -f "PostgreSQL" -a_srs EPSG:28992 -nlt CONVERT_TO_LINEAR -lco SPATIAL_INDEX=GIST -lco DIM=2 PG:"dbname=$DB host=$HOST port=$PORT" "$f"

  echo $TAB ends at $(date)

done

rm -rf TOP10NL* top10.g*

psql -U postgresadmin -h $HOST -p $PORT $DB << EOF

select * into waterdeel_punt from waterdeel where ST_GeometryType(wkb_geometry) = 'ST_Point';
ALTER TABLE waterdeel_punt ALTER COLUMN wkb_geometry type geometry(Point, 28992);
ALTER TABLE waterdeel_punt ADD CONSTRAINT waterdeel_punt_pkey PRIMARY KEY (ogc_fid);
CREATE INDEX waterdeel_punt_wkb_geometry_geom_idx ON public.waterdeel_punt USING gist (wkb_geometry) TABLESPACE pg_default;
select * into waterdeel_lijn from waterdeel where ST_GeometryType(wkb_geometry) = 'ST_LineString';
ALTER TABLE waterdeel_lijn ALTER COLUMN wkb_geometry type geometry(LineString, 28992);
ALTER TABLE waterdeel_lijn ADD CONSTRAINT waterdeel_lijn_pkey PRIMARY KEY (ogc_fid);
CREATE INDEX waterdeel_lijn_wkb_geometry_geom_idx ON public.waterdeel_lijn USING gist (wkb_geometry) TABLESPACE pg_default;
delete from waterdeel where ST_GeometryType(wkb_geometry) <> 'ST_Polygon';
ALTER TABLE waterdeel ALTER COLUMN wkb_geometry type geometry(Polygon, 28992);

select * into hoogte_punt from hoogte where ST_GeometryType(wkb_geometry) = 'ST_Point';
ALTER TABLE hoogte_punt ALTER COLUMN wkb_geometry type geometry(Point, 28992);
ALTER TABLE hoogte_punt ADD CONSTRAINT hoogte_punt_pkey PRIMARY KEY (ogc_fid);
CREATE INDEX hoogte_punt_wkb_geometry_geom_idx ON public.hoogte_punt USING gist (wkb_geometry) TABLESPACE pg_default;
delete from hoogte where ST_GeometryType(wkb_geometry) = 'ST_Point';
ALTER TABLE hoogte ALTER COLUMN wkb_geometry type geometry(LineString, 28992);

select * into wegdeel_punt from wegdeel where ST_GeometryType(wkb_geometry) = 'ST_Point';
ALTER TABLE wegdeel_punt ALTER COLUMN wkb_geometry type geometry(Point, 28992);
ALTER TABLE wegdeel_punt ADD CONSTRAINT wegdeel_punt_pkey PRIMARY KEY (ogc_fid);
CREATE INDEX wegdeel_punt_wkb_geometry_geom_idx ON public.wegdeel_punt USING gist (wkb_geometry) TABLESPACE pg_default;
select * into wegdeel_lijn from wegdeel where ST_GeometryType(wkb_geometry) = 'ST_LineString';
ALTER TABLE wegdeel_lijn ALTER COLUMN wkb_geometry type geometry(LineString, 28992);
ALTER TABLE wegdeel_lijn ADD CONSTRAINT wegdeel_lijn_pkey PRIMARY KEY (ogc_fid);
CREATE INDEX wegdeel_lijn_wkb_geometry_geom_idx ON public.wegdeel_lijn USING gist (wkb_geometry) TABLESPACE pg_default;
delete from wegdeel where ST_GeometryType(wkb_geometry) <> 'ST_Polygon';
ALTER TABLE wegdeel ALTER COLUMN wkb_geometry type geometry(Polygon, 28992);

select * into spoorbaandeel_punt from spoorbaandeel where ST_GeometryType(wkb_geometry) = 'ST_Point';
ALTER TABLE spoorbaandeel_punt ALTER COLUMN wkb_geometry type geometry(Point, 28992);
ALTER TABLE spoorbaandeel_punt ADD CONSTRAINT spoorbaandeel_punt_pkey PRIMARY KEY (ogc_fid);
CREATE INDEX spoorbaandeel_punt_wkb_geometry_geom_idx ON public.spoorbaandeel_punt USING gist (wkb_geometry) TABLESPACE pg_default;
delete from spoorbaandeel where ST_GeometryType(wkb_geometry) = 'ST_Point';
ALTER TABLE spoorbaandeel ALTER COLUMN wkb_geometry type geometry(LineString, 28992);

select * into plaats_punt from plaats where ST_GeometryType(wkb_geometry) = 'ST_Point';
ALTER TABLE plaats_punt ALTER COLUMN wkb_geometry type geometry(Point, 28992);
ALTER TABLE plaats_punt ADD CONSTRAINT plaats_punt_pkey PRIMARY KEY (ogc_fid);
CREATE INDEX plaats_punt_wkb_geometry_geom_idx ON public.plaats_punt USING gist (wkb_geometry) TABLESPACE pg_default;
delete from plaats where ST_GeometryType(wkb_geometry) = 'ST_Point';
-- MultiPolygon/Polygon
update plaats set wkb_geometry = st_multi(wkb_geometry) where ST_GeometryType(wkb_geometry) = 'ST_Polygon';
ALTER TABLE plaats ALTER COLUMN wkb_geometry type geometry(MultiPolygon, 28992);

-- MultiPolygon/Polygon
update registratiefgebied set wkb_geometry = st_multi(wkb_geometry) where ST_GeometryType(wkb_geometry) = 'ST_Polygon';
ALTER TABLE registratiefgebied ALTER COLUMN wkb_geometry type geometry(MultiPolygon, 28992);

select * into inrichtingselement_punt from inrichtingselement where ST_GeometryType(wkb_geometry) = 'ST_Point';
ALTER TABLE inrichtingselement_punt ALTER COLUMN wkb_geometry type geometry(Point, 28992);
ALTER TABLE inrichtingselement_punt ADD CONSTRAINT inrichtingselement_punt_pkey PRIMARY KEY (ogc_fid);
CREATE INDEX inrichtingselement_punt_wkb_geometry_geom_idx ON public.inrichtingselement_punt USING gist (wkb_geometry) TABLESPACE pg_default;
delete from inrichtingselement where ST_GeometryType(wkb_geometry) = 'ST_Point';
ALTER TABLE inrichtingselement ALTER COLUMN wkb_geometry type geometry(LineString, 28992);

select * into geografischgebied_punt from geografischgebied where ST_GeometryType(wkb_geometry) = 'ST_Point';
ALTER TABLE geografischgebied_punt ALTER COLUMN wkb_geometry type geometry(Point, 28992);
ALTER TABLE geografischgebied_punt ADD CONSTRAINT geografischgebied_punt_pkey PRIMARY KEY (ogc_fid);
CREATE INDEX geografischgebied_punt_wkb_geometry_geom_idx ON public.geografischgebied_punt USING gist (wkb_geometry) TABLESPACE pg_default;
delete from geografischgebied where ST_GeometryType(wkb_geometry) = 'ST_Point';
-- MultiPolygon/Polygon
update geografischgebied set wkb_geometry = st_multi(wkb_geometry) where ST_GeometryType(wkb_geometry) = 'ST_Polygon';
ALTER TABLE geografischgebied ALTER COLUMN wkb_geometry type geometry(MultiPolygon, 28992);

select * into gebouw_punt from gebouw where ST_GeometryType(wkb_geometry) = 'ST_Point';
ALTER TABLE gebouw_punt ALTER COLUMN wkb_geometry type geometry(Point, 28992);
ALTER TABLE gebouw_punt ADD CONSTRAINT gebouw_punt_pkey PRIMARY KEY (ogc_fid);
CREATE INDEX gebouw_punt_wkb_geometry_geom_idx ON public.gebouw_punt USING gist (wkb_geometry) TABLESPACE pg_default;
delete from gebouw where ST_GeometryType(wkb_geometry) = 'ST_Point';
ALTER TABLE gebouw ALTER COLUMN wkb_geometry type geometry(Polygon, 28992);

select * into functioneelgebied_punt from functioneelgebied where ST_GeometryType(wkb_geometry) = 'ST_Point';
ALTER TABLE functioneelgebied_punt ALTER COLUMN wkb_geometry type geometry(Point, 28992);
ALTER TABLE functioneelgebied_punt ADD CONSTRAINT functioneelgebied_punt_pkey PRIMARY KEY (ogc_fid);
CREATE INDEX functioneelgebied_punt_wkb_geometry_geom_idx ON public.functioneelgebied_punt USING gist (wkb_geometry) TABLESPACE pg_default;
delete from functioneelgebied where ST_GeometryType(wkb_geometry) = 'ST_Point';
-- MultiPolygon/Polygon
update functioneelgebied set wkb_geometry = st_multi(wkb_geometry) where ST_GeometryType(wkb_geometry) = 'ST_Polygon';
ALTER TABLE functioneelgebied ALTER COLUMN wkb_geometry type geometry(MultiPolygon, 28992);

EOF

# echo "select 'ALTER TABLE ' || tablename || ' drop column bronbeschrijving;' from pg_tables where schemaname = 'public' and tablename <> 'spatial_ref_sys';" | psql -U $PGU -h $HOST -p $PORT $DB -t | psql -U $PGU -h $HOST -p $PORT $DB

psql -U postgresadmin -h $HOST -p $PORT $DB << EOF
vacuum full verbose;
EOF

exit 0
