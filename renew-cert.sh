#!/bin/sh

PATH=/snap/bin:$PATH

HOSTNAME=tom-kad-k8s.westeurope.cloudapp.azure.com

microk8s.disable ingress

sudo certbot renew

sudo cp /etc/letsencrypt/live/$HOSTNAME/cert.pem /tmp
sudo cp /etc/letsencrypt/live/$HOSTNAME/privkey.pem /tmp
sudo chown $USER /tmp/*.pem

kubectl delete secrets testsecret-tls
kubectl create secret tls testsecret-tls --key /tmp/privkey.pem --cert /tmp/cert.pem

sudo rm /tmp/*.pem

microk8s.enable ingress
