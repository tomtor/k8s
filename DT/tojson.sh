PGHOST=localhost
PGUSER=tom
PGDB=bag3d
PGPORT=30258

GEMEENTE="0080" # Leeuwarden
GEMEENTE="0308" # Baarn

ogr2ogr -f "GeoJSON" $GEMEENTE.json PG:"host=$PGHOST port=$PGPORT user=$PGUSER dbname=$PGDB" \
        -s_srs EPSG:28992 -t_srs EPSG:4326 \
	-sql "select identificatie,openbareruimtenaam,huisnummer,woonplaatsnaam,st_force2d(geovlak),\"ground-0.50\" as ground50, \"roof-0.50\" as roof50 from \"3dbag\".pand3d, bagactueel.pand_compleet where identificatie = pandid and gemeentecode = '"$GEMEENTE"'"

cp $GEMEENTE.json /data/pythonapp/public/DT/data

