#!/bin/sh

for i in TOP*tif
do
  echo $i
  pct2rgb.py $i rgb.$i.tif
done

gdal_merge.py -of gtiff -co COMPRESS=JPEG -co PHOTOMETRIC=YCBCR -co TILED=YES -o top100.tif rgb*tif

gdaladdo -r average top100.tif 2 4 8 16 32

