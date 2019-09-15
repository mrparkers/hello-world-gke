#!/usr/bin/env sh

set -euo pipefail

# Apply Terraform, provision project, network, and cluster

terraform apply --auto-approve

clusterName=$(terraform output --json | jq -r '.gke_cluster_name.value')
clusterProject=$(terraform output --json | jq -r '.gke_cluster_project.value')
clusterRegion=$(terraform output --json | jq -r '.gke_cluster_region.value')
loadbalancerIP=$(terraform output --json | jq -r '.gke_loadbalancer_ip.value')

# Fetch cluster credentials

gcloud container clusters get-credentials --project ${clusterProject} --region ${clusterRegion} ${clusterName}

# Install cert-manager

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.10/deploy/manifests/00-crds.yaml
kubectl apply -f k8s/cert-manager/namespace.yml

helm repo add jetstack https://charts.jetstack.io # cert-manager
helm repo add stable https://kubernetes-charts.storage.googleapis.com/ # nginx
helm repo update

if !(helm status cert-manager -n cert-manager &> /dev/null); then
  helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --version 0.10.0 \
    --wait
fi

# Create CA and Certificate for SSL

kubectl apply -f k8s/cert-manager/self-signed-clusterissuer.yml
kubectl apply -f k8s/cert-manager/ca-certificate.yml
kubectl apply -f k8s/cert-manager/ca-issuer.yml
kubectl apply -f k8s/cert-manager/app-certificate.yml


# NGINX Ingress Controller

kubectl apply -f k8s/nginx/namespace.yml

if !(helm status nginx -n nginx &> /dev/null); then
  helm install nginx stable/nginx-ingress \
    --namespace nginx \
    --version 1.20.0 \
    --set-string controller.service.loadBalancerIP="${loadbalancerIP}" \
    --wait
fi

# Deploy app

if !(helm status app &> /dev/null); then
  helm install app k8s/app/
else
  helm upgrade app k8s/app/
fi

# Test!

kubectl get secret ca-certificate -o "jsonpath={.data['tls\.crt']}" | base64 -d > /usr/share/ca.crt

echo "${loadbalancerIP} hello-world-gke.app" >> /etc/hosts

curl --cacert /usr/share/ca.crt --silent https://hello-world-gke.app/ | jq '.'

kubectl patch deploy hello-world-gke -p "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"timestamp\": \"$(date +%s)\"}}}}}"

for i in $(seq 1 120); do
  curl --cacert /usr/share/ca.crt --silent https://hello-world-gke.app/ | jq -rc '.'
done
