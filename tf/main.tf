provider "google" {
  version = "2.14.0"
}

// the beta provider is needed for beta features, such as installing GKE-managed istio
provider "google-beta" {
  version = "2.14.0"
  alias   = "beta"
}

data "google_billing_account" "default_billing_account" {
  display_name = "My Billing Account" // by default, automatically created billing accounts have this name
  open         = true
}

resource "google_project" "project" {
  name       = var.gcloud_project_id
  project_id = var.gcloud_project_id

  auto_create_network = false // we will create our own network that is specifically designed for VPC-native clusters

  billing_account = data.google_billing_account.default_billing_account.id
}
