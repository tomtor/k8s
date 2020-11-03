PORT=5433
PORT=30778
HOST=localhost
PGU=tom
DB=top10

count=13534

while true;
do
echo $count
psql -U postgresadmin -h $HOST -p $PORT $DB << EOF

--set max_parallel_workers = 0;
select wkb_geometry from hoogte where ogc_fid = $count;
select max(ST_numpoints(wkb_geometry)) from hoogte where ogc_fid < $count;
select ST_numpoints(wkb_geometry) from hoogte where ogc_fid = $count;
-- select ST_GeometryType(wkb_geometry) from hoogte where ogc_fid = $count;
--select count(*) from hoogte where ST_GeometryType(wkb_geometry) = 'ST_Point' and ogc_fid <= $count;

EOF
count=$(expr $count \+ 1)
break
done
