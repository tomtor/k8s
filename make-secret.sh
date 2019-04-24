HOSTNAME=tom-kad-k8s.westeurope.cloudapp.azure.com

sudo certbot certonly --standalone -d $HOSTNAME -d k8s.v7f.eu -d pgadmin.v7f.eu -d mapserver.v7f.eu -d k8smon.v7f.eu

sudo cp /etc/letsencrypt/live/$HOSTNAME/fullchain.pem /tmp
sudo cp /etc/letsencrypt/live/$HOSTNAME/privkey.pem /tmp
sudo chown $USER /tmp/*.pem

kubectl create secret tls testsecret-tls --key /tmp/privkey.pem --cert /tmp/fullchain.pem
kubectl --namespace=kube-system create secret tls testsecret-tls --key /tmp/privkey.pem --cert /tmp/fullchain.pem

sudo rm /tmp/*.pem
