resource "google_compute_network" "vpc" {
  project     = google_project.project.id
  name        = "vpc"
  description = "Dedicated VPC for Hello World GKE exercise"

  auto_create_subnetworks = false
}

/*

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
    range_name    = "gke-pods"
  }

  secondary_ip_range {
    ip_cidr_range = "172.18.16.0/22"
    range_name    = "gke-services"
  }
}

// NAT

// free trial accounts have a quota of one IP address per region. you can increase this to two if you want HA and are not on the free trial
resource "google_compute_address" "nat_ip_address" {
  project = google_project.project.id
  region  = var.gcloud_region
  name    = "nat-ip-address-1"
}

resource "google_compute_router" "nat_router" {
  project = google_project.project.id
  network = google_compute_network.vpc.self_link
  name    = "nat-router"
  region  = var.gcloud_region
}

resource "google_compute_router_nat" "nat_gateway" {
  project = google_project.project.id
  name    = "nat-gateway-us-central1"
  router  = google_compute_router.nat_router.name
  region  = var.gcloud_region

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  min_ports_per_vm                   = 4096

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [
    google_compute_address.nat_ip_address.self_link
  ]
}
