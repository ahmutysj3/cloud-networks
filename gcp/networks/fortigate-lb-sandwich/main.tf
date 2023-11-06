data "google_compute_zones" "available" {
  region = var.gcp_region
}

data "google_compute_default_service_account" "default" {
}


resource "google_compute_project_metadata_item" "default" {
  key   = "serial-port-enable"
  value = "true"
}
