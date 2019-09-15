#!/usr/bin/env sh

# Apply Terraform, provision project, network, and cluster

terraform apply --auto-approve

clusterName=$(terraform output --json | jq -r '.gke_cluster_name.value')
clusterProject=$(terraform output --json | jq -r '.gke_cluster_project.value')
clusterRegion=$(terraform output --json | jq -r '.gke_cluster_region.value')

# Fetch cluster credentials

gcloud container clusters get-credentials --project ${clusterProject} --region ${clusterRegion} ${clusterName}

# Install cert-manager

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.10/deploy/manifests/00-crds.yaml
kubectl apply -f k8s/cert-manager/namespace.yml

helm repo add jetstack https://charts.jetstack.io
helm repo update

if !(helm status cert-manager -n cert-manager &> /dev/null); then
  helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --version 0.10.0
fi

# Create CA to sign SSL cert

kubectl apply -f k8s/cert-manager/ca-clusterissuer.yml
kubectl apply -f k8s/cert-manager/app-certificate.yml
