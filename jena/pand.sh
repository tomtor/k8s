export PGHOST=localhost
export PGPORT=30779

export BASE_DIR=$(pwd)/apache-sis-1.1
export SIS_DATA=$BASE_DIR/data

echo 'select gml_id, st_astext(st_transform(geometry,4326)), area from pand10' | psql -A -t bgt | awk -F\| '
BEGIN {
  print "<http://pand/asWKT> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#DatatypeProperty> ."
  print "<http://pand/asWKT> <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://www.opengis.net/ont/geosparql#asWKT> ."
  print "<http://pand/hasserial> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#DatatypeProperty> ."
  print "<http://pand/hasserial> <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://www.opengis.net/ont/geosparql#hasSerialization> ."
  print "<http://pand/hasGeometry> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#ObjectProperty> ."
  print "<http://pand/hasGeometry> <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://www.opengis.net/ont/geosparql#hasGeometry> ."
}
{
  #print "<http://bgt/pand/geometry/" $1 ">" " " "<http://pand/asWKT>" " " "\"<http://www.opengis.net/def/crs/EPSG/0/4326> " $2 "\"^^<http://www.opengis.net/ont/geosparql#wktLiteral> ."
  #print "<http://bgt/pand/geometry/" $1 ">" " " "<http://pand/hasserial>" " " "\"<http://www.opengis.net/def/crs/EPSG/0/4326> " $2 "\"^^<http://www.opengis.net/ont/geosparql#wktLiteral> ."
  print "<http://bgt/pand/geometry/" $1 ">" " " "<http://www.opengis.net/ont/geosparql#hasSerialization>" " " "\"<http://www.opengis.net/def/crs/EPSG/0/4326> " $2 "\"^^<http://www.opengis.net/ont/geosparql#wktLiteral> ."
  print "<http://bgt/pand/geometry/" $1 "> <http://pand/area> \"" $3 "\"^^<http://www.w3.org/2001/XMLSchema#float> ."
  #print "<http://bgt/pand/" $1 ">" " " "<http://pand/hasGeometry> <http://bgt/pand/geometry/" $1 "> ."
  print "<http://bgt/pand/" $1 ">" " " "<http://www.opengis.net/ont/geosparql#hasGeometry> <http://bgt/pand/geometry/" $1 "> ."
}
' > pand.nt

rm -rf tbd/*

java -Xmx3g -Djava.util.logging.config.file="logging.properties" -jar jena/jena-fuseki2/jena-fuseki-geosparql/target/jena-fuseki-geosparql-4.4.0-SNAPSHOT.jar -t tbd -t2 \
-dg -v \
-rf pand.nt
