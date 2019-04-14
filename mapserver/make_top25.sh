gdaltindex top25.shp top25/*.tif

for i in top25/*.tif
do
  echo $i
  gdal_translate -co TILED=YES $i tiled.tif
  gdaladdo -r average tiled.tif 2 4 8 16 32
  mv tiled.tif $i
done
