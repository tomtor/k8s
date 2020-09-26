PORT=30779
HOST=localhost
PGU=tom
DB=bgt

for f in *.gml # .gz
do
  TAB=$(echo "$f" | sed -e "s/bgt_//" -e "s/\\.gml.*//")

  echo $(date) start deleting: $TAB

  echo "delete from public.$TAB where objecteindtijd is not null or eindregistratie is not null;" | psql -U $PGU -h $HOST -p $PORT $DB

  echo $(date) end deleting of $TAB
  echo

done

exit 0
