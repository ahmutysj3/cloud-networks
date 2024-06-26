resource "google_compute_network" "this" {
  for_each                        = var.fw_networks
  name                            = "${var.prefix}-${each.key}-vpc"
  project                         = var.project
  auto_create_subnetworks         = false
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = each.key == "untrusted" || each.key == "mgmt" ? false : true
}

resource "google_compute_subnetwork" "this" {
  for_each      = var.fw_networks
  project       = var.project
  name          = "${var.prefix}-${each.key}-subnet"
  network       = google_compute_network.this[each.key].name
  ip_cidr_range = each.value
  region        = var.region
}


resource "google_compute_firewall" "this" {
  for_each = var.fw_networks
  project  = var.project
  name     = "${each.key}-fw"
  network  = google_compute_network.this[each.key].name
  allow {
    protocol = "all"
  }
  source_ranges = ["0.0.0.0/0"]

}
