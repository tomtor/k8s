curl http://geodata.nationaalgeoregister.nl/top50nl/extract/chunkdata/top50nl_gml_filechunks.zip?formaat=gml --output top50.zip
unzip -o top50.zip

./load.sh
