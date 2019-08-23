PGHOST=localhost
PGUSER=tom
PGDB=bag3d
PGPORT=30258

PSQL="psql -h $PGHOST -p $PGPORT -U $PGUSER"

$PSQL postgres -c "create database \"$PGDB\";"

psql --set=sslmode=require -h $PGHOST -p $PGPORT -U postgresadmin -c "create extension postgis;" $PGDB

$PSQL $PGDB -c "create schema \"3dbag\";"

pg_restore --no-owner --no-privileges -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDB -w bagactueel_schema.backup 
pg_restore --no-owner --no-privileges --clean -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDB -w bag3d_2019-07-28.backup
