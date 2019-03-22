DATE=$(date  --rfc-3339=date)

echo $DATE

# pg_dump -Fc -h localhost -U tom -p 31082 tom | pv | az storage blob upload  --container-name public --account-name tomvcool --file /dev/stdin --name "tom.$DATE.backup"

pg_dump -Fc -Z 1 -h localhost -U postgresadmin -p 31082 tom | pv | azbak --no-suffix - "/public/tom.$DATE.backup"

#pg_dump -Fc -Z 1 -h localhost -U postgresadmin -p 31082 nlextract | pv | azbak --no-suffix - "/public/nlextract.$DATE.backup"

exit 0

pg_dump -Fc -h localhost -U tom -p 31082 tom > tom.$DATE.backup
pg_dump -Fc -h localhost -U postgresadmin -p 31082 nlextract > nlextract.$DATE.backup
