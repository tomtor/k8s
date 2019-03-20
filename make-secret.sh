sudo certbot certonly --standalone -d tom-kad-ssh.westeurope.cloudapp.azure.com

sudo cp /etc/letsencrypt/live/tom-kad-ssh.westeurope.cloudapp.azure.com/cert.pem /tmp
sudo cp /etc/letsencrypt/live/tom-kad-ssh.westeurope.cloudapp.azure.com/privkey.pem /tmp
sudo chmod 644 /tmp/*.pem

kubectl create secret tls testsecret-tls --key /tmp/privkey.pem --cert /tmp/cert.pem

sudo rm /tmp/*.pem
