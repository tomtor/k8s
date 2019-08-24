PGHOST=localhost
PGUSER=tom
PGDB=bag3d
PGPORT=30258

ogr2ogr -f "GML" mykml.gml PG:"host=$PGHOST port=$PGPORT user=$PGUSER dbname=$PGDB" \
        "3dbag.pand3d" -s_srs EPSG:28992 -t_srs EPSG:4326 \
	-where "tile_id = '07fz1'"

#	-sql "select geovlak from \"3dbag\".pand3d where tile_id = '07fz1'"

