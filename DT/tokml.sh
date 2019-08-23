PGHOST=localhost
PGUSER=tom
PGDB=bag3d
PGPORT=30258

ogr2ogr -f "KML" mykml.kml PG:"host=$PGHOST port=$PGPORT user=$PGUSER dbname=$PGDB" \
        -s_srs EPSG:28992 -t_srs EPSG:4326 \
	-sql "select geovlak from \"3dbag\".pand3d where tile_id = '07fz1'"

