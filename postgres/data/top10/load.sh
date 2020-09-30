PORT=30779
HOST=localhost
PGU=tom
DB=top10

SRC=TOP10NL_GML_Filechuncks_*/TOP10NL_GML_Filechuncks/

dropdb -U $PGU -h $HOST -p $PORT $DB
createdb -U $PGU -h $HOST -p $PORT $DB
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

exit 0
