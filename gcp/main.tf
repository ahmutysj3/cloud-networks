resource "google_compute_network" "main" {
  for_each                = var.vpc_params
  project                 = var.gcp_project
  auto_create_subnetworks = false
  name                    = "main-${each.key}-vpc"
}
