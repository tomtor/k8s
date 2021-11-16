export PGHOST=localhost
export PGPORT=30779

echo 'select gml_id, latlong from pand10' | psql -A -t brk | awk -F\| '
BEGIN {
  print "<http://geo.linkedopendata.gr/gag/ontology/asWKT> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#DatatypeProperty> ."
  print "<http://geo.linkedopendata.gr/gag/ontology/asWKT> <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://www.opengis.net/ont/geosparql#asWKT> ."
}
{ print "<http://bgt/pand/geometry/" $1 ">" " " "<http://geo.linkedopendata.gr/gag/ontology/asWKT>" " " "\"<http://www.opengis.net/def/crs/EPSG/4326> " $2 "\"^^<http://www.opengis.net/ont/geosparql#wktLiteral> ."
}
' > pand.nt

echo 'select gml_id, latlong from perceel10' | psql -A -t brk | awk -F\| '
{ print "<http://brk/perceel/geometry/" $1 ">" " " "<http://geo.linkedopendata.gr/gag/ontology/asWKT>" " " "\"<http://www.opengis.net/def/crs/EPSG/4326> " $2 "\"^^<http://www.opengis.net/ont/geosparql#wktLiteral> ."
}
' > perceel.nt

rm -f tbd/*

java -jar jena/jena-fuseki2/jena-fuseki-geosparql/target/jena-fuseki-geosparql-4.3.0-SNAPSHOT.jar -t tbd \
 -rf pand.nt \
 -rf perceel.nt \
 -i

exit 0

sed 's/gag\/geometry\/[0-9]*/&c1/g' < gag.nt > gagc1.nt
sed 's/gag\/geometry\/[0-9]*/&c2/g' < gag.nt > gagc2.nt

rm -f tbd/*

java -jar jena/jena-fuseki2/jena-fuseki-geosparql/target/jena-fuseki-geosparql-4.3.0-SNAPSHOT.jar -t tbd \
 -rf gag.nt \
 -rf gagc1.nt \
 -rf gagc2.nt \
 -i
