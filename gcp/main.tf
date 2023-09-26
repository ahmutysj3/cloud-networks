resource "google_compute_network" "main" {
  count = 1
  project                 = var.gcp_project
  auto_create_subnetworks = false
  name                    = "main-test-vpc"
}
