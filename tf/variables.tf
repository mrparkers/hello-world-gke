variable "gcloud_project_id" {
  type = "string"
}

variable "gcloud_region" {
  type    = "string"
  default = "us-central1"
}

variable "gke_pod_subnet_name" {
  type    = "string"
  default = "gke-pods"
}

variable "gke_service_subnet_name" {
  type    = "string"
  default = "gke-services"
}
