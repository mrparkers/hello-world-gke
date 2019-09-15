resource "google_compute_firewall" "allow_https" {
  project = google_project.project.id
  name    = "allow-http"
  network = google_compute_network.vpc.id

  target_tags = [
    "gke"
  ]

  allow {
    protocol = "tcp"
    ports = [
      443, # https
      80,  # http -> https redirect
    ]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}
