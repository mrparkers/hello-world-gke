resource "google_compute_network" "vpc" {
  project     = google_project.project.id
  name        = "vpc"
  description = "Dedicated VPC for Hello World GKE exercise"

  auto_create_subnetworks = false
}

/*

  The subnet below will be consumed by our VPC-native cluster (https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips)

  Subnet CIDR math:

  -- GKE Master Nodes (172.18.20.0/28) --

  The master nodes are deployed to a GCP managed project and are peered to our project using VPC Network Peering
  These nodes take a /28, and this currently cannot be changed. This /28 cannot be reserved in our VPC, so we have to
  be careful to not accidentally reserve it ourselves.

  -- GKE Cluster Nodes (172.18.20.16/28) --

  Our cluster does not have to be very large for this exercise. A /28 will give us a 12 node cluster.

  -- GKE Pods (172.18.0.0/20) --

  GKE imposes a limit of 110 pods per node. Each node will grab a /24 from the pod range to give it enough room to easily
  reuse IP addresses when pods are added and removed from nodes. Using a /20 for our pod range will allow us to allocate
  16 /24 ranges, which will be enough for our 12 node cluster (4 /24 ranges will go unused)

  -- GKE Services (172.18.16.0/22)

  Given our limit of 110 pods per node in a 12 node cluster, we can have a maximum of 1320 pods. A /22 gives us 1020 service
  IP addresses, which should be enough given that services are likely to be assigned to two or more pods.

*/

resource "google_compute_subnetwork" "vpc_k8s" {
  project                  = google_project.project.id
  ip_cidr_range            = "172.18.20.16/28" // node range
  name                     = "hello-world-gke-us-central1"
  description              = "Subnet for VPC Native GKE cluster"
  network                  = google_compute_network.vpc.id
  region                   = var.gcloud_region
  enable_flow_logs         = true
  private_ip_google_access = true

  secondary_ip_range {
    ip_cidr_range = "172.18.0.0/20"
    range_name    = var.gke_pod_subnet_name
  }

  secondary_ip_range {
    ip_cidr_range = "172.18.16.0/22"
    range_name    = var.gke_service_subnet_name
  }
}

resource "google_compute_address" "loadbalancer_ip" {
  project = google_project.project.id
  region  = var.gcloud_region
  name    = "loadbalancer-ip"
}
