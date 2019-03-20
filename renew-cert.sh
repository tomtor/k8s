#!/bin/sh

PATH=/snap/bin:$PATH

microk8s.disable ingress

sudo certbot renew

sudo cp /etc/letsencrypt/live/tom-kad-ssh.westeurope.cloudapp.azure.com/cert.pem /tmp
sudo cp /etc/letsencrypt/live/tom-kad-ssh.westeurope.cloudapp.azure.com/privkey.pem /tmp
sudo chmod 644 /tmp/*.pem

kubectl delete secrets testsecret-tls
kubectl create secret tls testsecret-tls --key /tmp/privkey.pem --cert /tmp/cert.pem

sudo rm /tmp/*.pem

microk8s.enable ingress
