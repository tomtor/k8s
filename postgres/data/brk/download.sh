curl -L https://downloads.pdok.nl/kadastralekaart/api/v4_0/full/predefined/dkk-gml-nl-nohist.zip --output brk.zip
unzip -o brk.zip dkk_openbareruimtelabel.gml dkk_perceel.gml 
rm brk.zip

./load.sh
