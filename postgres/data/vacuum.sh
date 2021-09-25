PORT=30779
HOST=localhost
PGU=tom
DB=postgres

for DBL in $(
  psql -c "SELECT datname FROM pg_database;" -t -U $PGU -h $HOST -p $PORT $DB
  )
do

  echo $(date) start vacuum analyze: $DBL

  echo "vacuum verbose analyze;" | psql -U $PGU -h $HOST -p $PORT $DBL

  echo $(date) end vacuum of $DBL
  echo

done

exit 0
