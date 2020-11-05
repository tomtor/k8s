PORT=30779
HOST=localhost
PGU=tom
DB=bgt

for TAB in $(echo "select tablename from pg_tables where tablename like 'bag_%'" | \
    psql -U $PGU -h $HOST -p $PORT -d $DB -t)
do
  # if test $TAB = "bag_verblijfsobject"; then echo Skip $TAB continue; fi
  echo $(date) start clustering: $TAB

  INDEX=$(echo "SELECT indexname FROM pg_indexes WHERE tablename = '$TAB' and indexname not like '%pkey'" | \
    psql -U $PGU -h $HOST -p $PORT -d $DB -t)

  if test -n "$INDEX"; then
    echo "CLUSTER VERBOSE public.$TAB USING ${INDEX};" | psql -U $PGU -h $HOST -p $PORT $DB
  else
    echo "VACUUM FULL public.$TAB;" | psql -U $PGU -h $HOST -p $PORT $DB
  fi

  echo $(date) end clustering of $TAB
  echo

done

exit 0
