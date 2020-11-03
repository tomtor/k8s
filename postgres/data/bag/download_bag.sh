curl http://geodata.nationaalgeoregister.nl/inspireadressen/extract/inspireadressen.zip --output inspire-adressen.zip

unzip inspire-adressen.zip

#unzip *PND*.zip
for f in 9999*.zip
do
  unzip -o "$f"
done

rm *.zip

sh load-bag.sh
sh clean-bag.sh
sh fix-woonplaats.sh
sh cluster-bag.sh
rm *.xml
