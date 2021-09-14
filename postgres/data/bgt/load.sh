PORT=30779
HOST=localhost
PGU=tom
DB=bgt

dropdb -U $PGU -h $HOST -p $PORT $DB
createdb -U $PGU -h $HOST -p $PORT $DB

echo "CREATE DATABASE $DB TEMPLATE template0 LC_COLLATE 'nl_NL.UTF-8' LC_CTYPE 'nl_NL.UTF-8';" | psql -U $PGU -h $HOST -p $PORT postgres

echo "create extension postgis;" | psql -U postgresadmin -h $HOST -p $PORT $DB

for f in *.gml # .gz
do
  TAB=$(echo "$f" | sed -e "s/bgt_//" -e "s/\\.gml.*//")
  echo $TAB starts at $(date)

  ogr2ogr -progress -f "PostgreSQL" -overwrite -where "objecteindtijd is null and eindregistratie is null" -a_srs EPSG:28992 -nlt CONVERT_TO_LINEAR -lco GEOMETRY_NAME=wkb_geometry -lco SPATIAL_INDEX=GIST -lco DIM=2 PG:"dbname=$DB host=$HOST port=$PORT" "$f"

  #echo "ALTER TABLE public.$TAB RENAME geometrie2d to wkb_geometry;" | psql -U $PGU -h $HOST -p $PORT $DB

  # echo "ALTER TABLE public.$TAB CLUSTER ON ${TAB}_wkb_geometry_geom_idx;" | psql -U $PGU -h $HOST -p $PORT $DB
  echo $TAB ends at $(date)

done
