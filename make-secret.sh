HOSTNAME=tom-kad-k8s.westeurope.cloudapp.azure.com

sudo certbot certonly --pre-hook "microk8s.disable ingress; sleep 3" --post-hook "microk8s.enable ingress" \
	--standalone -d $HOSTNAME -d k8s.v7f.eu -d pgadmin.v7f.eu -d mapserver.v7f.eu -d k8smon.v7f.eu -d geoserver.v7f.eu

sudo cp /etc/letsencrypt/live/$HOSTNAME/fullchain.pem /tmp
sudo cp /etc/letsencrypt/live/$HOSTNAME/privkey.pem /tmp
sudo chown $USER /tmp/*.pem

kubectl create secret tls testsecret-tls --key /tmp/privkey.pem --cert /tmp/fullchain.pem --dry-run -o yaml | kubectl apply -f -
kubectl --namespace=kube-system create secret tls testsecret-tls --key /tmp/privkey.pem --cert /tmp/fullchain.pem --dry-run -o yaml | kubectl apply -f -

sudo rm /tmp/*.pem
