PGHOST=localhost
PGUSER=tom
PGDB=bag3d
PGPORT=30258

GEMEENTE="0308"

ogr2ogr -f "GeoJSON" $GEMEENTE.json PG:"host=$PGHOST port=$PGPORT user=$PGUSER dbname=$PGDB" \
        "3dbag.pand3d" -s_srs EPSG:28992 -t_srs EPSG:28992 \
	-select identificatie,geovlak,ground-0.50,roof-0.50 \
	-where "gemeentecode = '"$GEMEENTE"'"

#	-sql "select geovlak from \"3dbag\".pand3d where tile_id = '07fz1'"

