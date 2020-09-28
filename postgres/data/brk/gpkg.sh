PORT=30779
HOST=localhost
PGU=tom
DB=brk

ogr2ogr -progress -f "gpkg" -a_srs EPSG:28992 brk.gpkg PG:"dbname=$DB host=$HOST port=$PORT"
