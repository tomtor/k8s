#!/bin/sh

PATH=/snap/bin:$PATH

HOSTNAME=tom-kad-k8s.westeurope.cloudapp.azure.com

sudo certbot renew --pre-hook "microk8s.disable ingress" --post-hook "microk8s.enable ingress"

sudo cp /etc/letsencrypt/live/$HOSTNAME/fullchain.pem /tmp
sudo sh -c "umask 377; cp /etc/letsencrypt/live/$HOSTNAME/privkey.pem /tmp"
sudo chown $USER /tmp/*.pem

kubectl delete secrets testsecret-tls
kubectl create secret tls testsecret-tls --key /tmp/privkey.pem --cert /tmp/fullchain.pem

sudo rm /tmp/*.pem
