#!/bin/sh

HOSTNAME=tom-kad-k8s.westeurope.cloudapp.azure.com

PATH=/snap/bin:$PATH

CRDIR=/tmp/cert_renew_$$

mkdir $CRDIR

sudo certbot renew --pre-hook "microk8s.disable ingress" --post-hook "microk8s.enable ingress"

sudo cp /etc/letsencrypt/live/$HOSTNAME/fullchain.pem $CRDIR
sudo sh -c "umask 077; cp /etc/letsencrypt/live/$HOSTNAME/privkey.pem $CRDIR"
sudo chown $USER $CRDIR/*.pem

kubectl create secret tls testsecret-tls --key $CRDIR/privkey.pem --cert $CRDIR/fullchain.pem --dry-run -o yaml | kubectl apply -f -

rm -rf $CRDIR
