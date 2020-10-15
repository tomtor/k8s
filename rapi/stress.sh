while :
do

for i in 1 2 3 4 5 6 7 8 9 10
do
curl localhost:8000/lokaalid/[1-1000] -s -o /dev/null &
done

wait
date 

done
