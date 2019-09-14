// cluster

resource "google_container_cluster" "gke_cluster" {
  provider           = "google-beta.beta"
  project            = google_project.project.id
  name               = "hello-world-gke"
  min_master_version = "1.14.3-gke.11"
  location           = var.gcloud_region

  private_cluster_config {
    master_ipv4_cidr_block  = "172.18.20.0/28"
    enable_private_nodes    = false
    enable_private_endpoint = false
  }

  node_locations = [
    "${var.gcloud_region}-a",
    "${var.gcloud_region}-b",
    "${var.gcloud_region}-c",
  ]

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  // this must be empty so basic auth is disabled
  master_auth {
    password = ""
    username = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "06:00"
    }
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  addons_config {
    // l7 load balancer addon isn't needed since the gateway in the cluster will handle SSL termination
    http_load_balancing {
      disabled = true
    }

    network_policy_config {
      disabled = false
    }

    istio_config {
      disabled = false
      auth     = "AUTH_MUTUAL_TLS"
    }
  }

  pod_security_policy_config {
    enabled = false
  }

  network                     = google_compute_network.vpc.self_link
  subnetwork                  = google_compute_subnetwork.vpc_k8s.self_link
  enable_intranode_visibility = true

  ip_allocation_policy {
    cluster_secondary_range_name  = var.gke_pod_subnet_name
    services_secondary_range_name = var.gke_service_subnet_name
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "0.0.0.0/0"
    }
  }

  initial_node_count       = 1
  remove_default_node_pool = true

  depends_on = [
    google_project_service.services
  ]
}

// node pool service account

resource "google_service_account" "gke_node_pool_svc" {
  project    = google_project.project.id
  account_id = "gke-node-pool"
}

// the following permissions are needed so the cluster's logs and events can be exported to StackDriver
resource "google_project_iam_member" "gke_node_pool_svc_permissions" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.viewer",
    "roles/monitoring.metricWriter",
  ])

  project = google_project.project.id
  member  = "serviceAccount:${google_service_account.gke_node_pool_svc.email}"
  role    = each.value
}

// node pool
resource "google_container_node_pool" "standard_v4_us_central1" {
  provider   = "google-beta.beta"
  project    = google_project.project.id
  name       = "gke-standard-node-pool"
  cluster    = google_container_cluster.gke_cluster.id
  node_count = 1
  location   = var.gcloud_region
  version    = "1.14.3-gke.11"

  node_config {
    service_account = google_service_account.gke_node_pool_svc.email
    preemptible     = false
    machine_type    = "n1-standard-2"
    image_type      = "COS"
    // free accounts have a max of 100gb of ssd space per region, meaning three nodes can have 33gb each
    disk_size_gb    = 33
    disk_type       = "pd-ssd"

    tags = [
      "gke",
    ]
  }
}

