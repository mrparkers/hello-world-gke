#!/usr/bin/env sh

set -euo pipefail

# Apply Terraform, provision project, network, and cluster

printf "\n\n----- Creating project, network, and cluster -----\n\n"

echo "You will be prompted for a \`gcloud_project_id\` variable. This will uniquely identify your project in GCP."
echo "You can create a \`terraform.tfvars\` file to avoid being prompted for this in the future."
terraform apply

clusterName=$(terraform output --json | jq -r '.gke_cluster_name.value')
clusterProject=$(terraform output --json | jq -r '.gke_cluster_project.value')
clusterRegion=$(terraform output --json | jq -r '.gke_cluster_region.value')
loadbalancerIP=$(terraform output --json | jq -r '.gke_loadbalancer_ip.value')

printf "\n\n----- Applying Kubernetes manifest files -----\n\n"

# Fetch cluster credentials

gcloud container clusters get-credentials --project ${clusterProject} --region ${clusterRegion} ${clusterName}

# Verify cluster can receive API requests

kubectl rollout status deploy/calico-node-vertical-autoscaler -n kube-system
kubectl rollout status deploy/calico-typha-horizontal-autoscaler -n kube-system
kubectl rollout status deploy/calico-typha-vertical-autoscaler -n kube-system
kubectl rollout status deploy/kube-dns -n kube-system

# Install cert-manager

helm repo add jetstack https://charts.jetstack.io # cert-manager
helm repo add stable https://kubernetes-charts.storage.googleapis.com/ # nginx
helm repo update

printf "\n\n----- Installing cert-manager -----\n\n"

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.10/deploy/manifests/00-crds.yaml
kubectl apply -f k8s/cert-manager/namespace.yml

echo "This next step may appear to throw an error. This is okay, the script will handle it."
if !(helm status cert-manager -n cert-manager &> /dev/null); then
  while !(helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --version 0.10.0 \
    --wait); do
    sleep 5;
  done;
fi

kubectl rollout status deploy/cert-manager -n cert-manager
kubectl rollout status deploy/cert-manager-webhook -n cert-manager
kubectl rollout status deploy/cert-manager-cainjector -n cert-manager

# Create CA and Certificate for SSL

kubectl apply -f k8s/cert-manager/self-signed-clusterissuer.yml
kubectl apply -f k8s/cert-manager/ca-certificate.yml
kubectl apply -f k8s/cert-manager/ca-issuer.yml
kubectl apply -f k8s/cert-manager/app-certificate.yml

printf "\n\n----- Installing nginx-ingress-controller -----\n\n"

# NGINX Ingress Controller

kubectl apply -f k8s/nginx/namespace.yml

if !(helm status nginx -n nginx &> /dev/null); then
  helm install nginx stable/nginx-ingress \
    --namespace nginx \
    --version 1.20.0 \
    --set-string controller.service.loadBalancerIP="${loadbalancerIP}" \
    --wait
fi

printf "\n\n----- Deploying App -----\n\n"

# Deploy app

if !(helm status app &> /dev/null); then
  helm install app k8s/app/
else
  helm upgrade app k8s/app/
fi

kubectl rollout status deploy/hello-world-gke

# Test!

printf "\n\n----- Testing App -----\n\n"

kubectl get secret ca-certificate -o "jsonpath={.data['tls\.crt']}" | base64 -d > /usr/share/ca.crt

hostRecord="${loadbalancerIP} hello-world-gke.app"
echo ${hostRecord} >> /etc/hosts

until curl --cacert /usr/share/ca.crt --silent https://hello-world-gke.app/ --max-time 3 | jq '.' &> /dev/null; do
  echo "Waiting for load balancer..."
done

curl --cacert /usr/share/ca.crt --silent https://hello-world-gke.app/ | jq '.'

printf "\n\n----- Testing App Rolling Deployment (none of these requests should fail) -----\n\n"

kubectl patch deploy hello-world-gke -p "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"timestamp\": \"$(date +%s)\"}}}}}"
for i in $(seq 1 120); do
  curl --cacert /usr/share/ca.crt --silent https://hello-world-gke.app/ | jq -rc '.'
done

printf "\n\nFinished!  The following host record can be added to test this yourself:\n"
echo ${hostRecord}

echo "Once this is added, you can hit https://hello-world-gke.app in your browser."
