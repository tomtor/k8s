DEST=10.152.183.30
DEST=localhost
DEST=fuseki.v7f.eu

PORT=9030
PORT=443

HTTP=http
HTTP=https

# load STW vocabulary data
#curl --user tom:$FKPW -I -X POST -H Content-Type:text/turtle -T stw.ttl -G $HTTP://$DEST:$PORT/skosmos/data --data-urlencode graph=http://zbw.eu/stw/

GRAPH=http://opendata.stelselcatalogus.nl/stelsel/

curl -X DELETE $HTTP://$DEST:$PORT/skosmos/data --data-urlencode graph=$GRAPH

rm -f stelselcatalogus.ttl
wget https://www.stelselcatalogus.nl/downloads/stelselcatalogus.ttl
sed 's/a sc:Begrip/&, skos:Concept/' < stelselcatalogus.ttl > sc-in.ttl
skosify sc-in.ttl -o sc.ttl

curl -I -X POST -H Content-Type:text/turtle -T sc.ttl -G $HTTP://$DEST:$PORT/skosmos/data --data-urlencode graph=$GRAPH

exit 0

rm -f kad.ttl
wget https://github.com/bp4mc2/bp4mc2-zvg/raw/master/taxonomie%C3%ABn/kad.ttl

curl -I -X POST -H Content-Type:text/turtle -T kad.ttl -G $HTTP://$DEST:$PORT/skosmos/data --data-urlencode graph=http://zorgeloosvastgoed.nl/kad/

# load UNESCO vocabulary data
curl -I -X POST -H Content-Type:text/turtle -T unescothes.ttl -G $HTTP://$DEST:$PORT/skosmos/data --data-urlencode graph=http://skos.um.es/unescothes/

