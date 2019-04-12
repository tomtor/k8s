gdaltindex top100.shp top100/*.tif

for i in top100/*.tif
do
  echo $i
  gdaladdo -r average $i 2 4 8 16
done
