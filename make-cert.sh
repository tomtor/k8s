microk8s.disable ingress

sudo certbot certonly --standalone --cert-name  tom-kad-k8s.westeurope.cloudapp.azure.com -d k8s.v7f.eu -d pgadmin.v7f.eu -d egeria.v7f.eu -d tom-kad-k8s.westeurope.cloudapp.azure.com -d skosmos.v7f.eu -d fuseki.v7f.eu -d lab-pres.v7f.eu -d vocbench.v7f.eu

microk8s.enable ingress
sh renew-cert.sh
