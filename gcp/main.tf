resource "google_compute_network" "hub_inside" {
  project                 = var.gcp_project
  name                    = "hub_inside"
  auto_create_subnetworks = false
  delete_default_routes_on_create = true
}

resource "google_compute_network" "hub_outside" {
    project                 = var.gcp_project
    name                    = "hub_outside"
    auto_create_subnetworks = false
    delete_default_routes_on_create = true
}

resource "google_compute_network" "hub_mgmt" {
    project                 = var.gcp_project
    name                    = "hub_mgmt"
    auto_create_subnetworks = false
    delete_default_routes_on_create = true
}

resource "google_compute_network" "hub_ha" {
    project                 = var.gcp_project
    name                    = "hub_ha"
    auto_create_subnetworks = false
    delete_default_routes_on_create = true
}