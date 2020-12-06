microk8s.enable dns
microk8s.enable ingress

kubectl apply -f postgres/postgres-storage.yaml
kubectl apply -f postgres/secret.yaml
kubectl apply -f postgres/postgres-service.yaml
kubectl apply -f postgres/postgres-deployment.yaml

kubectl apply -f postgres/pgadmin4-config.yaml
kubectl apply -f postgres/pgadmin-service.yaml
kubectl apply -f postgres/pgadmin-deploy.yaml

sh ./renew-cert.sh
kubectl apply -f test_ingress.yaml

kubectl apply -f redis/redis-master-service.yaml
kubectl apply -f redis/redis-master-deploy.yaml

kubectl apply -f docker-python/pythonapp-config.yaml
kubectl apply -f docker-python/pythonapp-deploy.yaml
