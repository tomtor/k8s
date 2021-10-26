DEST=10.152.183.30
DEST=localhost
DEST=fuseki.v7f.eu

PORT=9030
PORT=443

HTTP=http
HTTP=https

curl -I -X POST -H Content-Type:text/turtle -T kad.ttl -G $HTTP://$DEST:$PORT/skosmos/data --data-urlencode graph=http://zorgeloosvastgoed.nl/kad/

exit 0

# load STW vocabulary data
curl -I -X POST -H Content-Type:text/turtle -T stw.ttl -G $HTTP://$DEST:$PORT/skosmos/data --data-urlencode graph=http://zbw.eu/stw/
# load UNESCO vocabulary data
curl -I -X POST -H Content-Type:text/turtle -T unescothes.ttl -G $HTTP://$DEST:$PORT/skosmos/data --data-urlencode graph=http://skos.um.es/unescothes/

