#! /bin/sh

HOSTNAME=tom-kad-k8s.westeurope.cloudapp.azure.com

#PGDIR=/data/pg11/pg11.2
#PGDIR=/data/pg/pg12.0beta
PGDIR=/data/pg/pg12
PGOWNER=70

PATH=/snap/bin:$PATH

CRDIR=/tmp/cert_renew_$$

mkdir $CRDIR

sudo certbot renew --pre-hook "microk8s.disable ingress; sleep 3" --post-hook "microk8s.enable ingress"

sudo cp /etc/letsencrypt/live/$HOSTNAME/fullchain.pem $CRDIR
sudo sh -c "umask 077; cp /etc/letsencrypt/live/$HOSTNAME/privkey.pem $CRDIR"
sudo chown $USER $CRDIR/*.pem

kubectl create secret tls testsecret-tls --key $CRDIR/privkey.pem --cert $CRDIR/fullchain.pem --dry-run=client -o yaml | kubectl apply -f -
kubectl --namespace=kube-system create secret tls testsecret-tls --key $CRDIR/privkey.pem --cert $CRDIR/fullchain.pem --dry-run=client -o yaml | kubectl apply -f -

rm -rf $CRDIR

sudo cp /etc/letsencrypt/live/$HOSTNAME/fullchain.pem $PGDIR/server.crt
sudo cp /etc/letsencrypt/live/$HOSTNAME/privkey.pem $PGDIR/server.key
sudo chown $PGOWNER.$PGOWNER $PGDIR/server.key
sudo chmod 0600 $PGDIR/server.key
