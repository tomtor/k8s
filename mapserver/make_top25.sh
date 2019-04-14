gdaltindex top25.shp top25/*.tif

for i in top25/*.tif
do
  echo $i
  gdal_translate -co TILED=YES $i tiled.tif
  gdaladdo -r average tiled.tif 2 4 8 16 32
  mv tiled.tif $i
done

gdalwarp -srcnodata "255 255 255" -tr 32 32 -overwrite top25/*-2*tif top25-32.tif
