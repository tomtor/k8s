#!/bin/sh

for i in TOP*tif
do
  echo $i
  pct2rgb.py $i rgb.$i
done

gdal_merge.py -of gtiff -co COMPRESS=JPEG -co PHOTOMETRIC=YCBCR -co TILED=YES -o top100.tif rgb*tif

gdaladdo -r average top100.tif 2 4 8 16 32

raster2pgsql -s 28992 -I -Y -e -F -t 250x250 -l 2,4,8,16 -C rgb*TOP*tif public.top100raster | psql -h localhost -U tom tom
