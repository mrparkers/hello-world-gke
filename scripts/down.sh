#!/usr/bin/env sh

set -euo pipefail

clusterName=$(terraform output --json | jq -r '.gke_cluster_name.value')
clusterProject=$(terraform output --json | jq -r '.gke_cluster_project.value')
clusterRegion=$(terraform output --json | jq -r '.gke_cluster_region.value')
loadbalancerIP=$(terraform output --json | jq -r '.gke_loadbalancer_ip.value')

gcloud container clusters get-credentials --project ${clusterProject} --region ${clusterRegion} ${clusterName}

helm uninstall app
helm uninstall nginx -n nginx
helm uninstall cert-manager -n cert-manager

kubectl delete ns nginx
kubectl delete ns cert-manager

kubectl delete certificate app-certificate ca-certificate
kubectl delete issuer ca-issuer
kubectl delete clusterissuer self-signed-clusterissuer

terraform destroy
