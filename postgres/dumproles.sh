POD=$(kubectl get pods | grep postgres | cut -d' ' -f1)

echo "POD: " $POD

kubectl exec $POD -- pg_dumpall --roles-only -U postgresadmin > roles.sql
