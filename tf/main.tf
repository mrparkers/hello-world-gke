provider "google" {
  version = "2.14.0"
}

data "google_billing_account" "default_billing_account" {
  display_name = "My Billing Account" // by default, automatically created billing accounts have this name
  open         = true
}

output "billing_account_id" {
  value = data.google_billing_account.default_billing_account.id
}
