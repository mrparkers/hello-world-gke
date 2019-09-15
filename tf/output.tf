output "gke_cluster_name" {
  value = google_container_cluster.gke_cluster.name
}

output "gke_cluster_project" {
  value = google_container_cluster.gke_cluster.project
}

output "gke_cluster_region" {
  value = google_container_cluster.gke_cluster.region
}

output "gke_loadbalancer_ip" {
  value = google_compute_address.loadbalancer_ip.address
}
