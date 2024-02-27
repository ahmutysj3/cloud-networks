resource "google_compute_network" "this" {
  for_each                        = var.fw_networks
  name                            = "wsky-test-${each.key}-vpc"
  project                         = var.project
  auto_create_subnetworks         = false
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = each.key == "untrusted" || each.key == "mgmt" ? false : true
}

output "fw_networks" {
  value = {
    for k, v in google_compute_network.this : k => {
      name      = v.name
      self_link = v.self_link
  } }
}


resource "google_compute_subnetwork" "this" {
  for_each      = var.fw_networks
  project       = var.project
  name          = "wsky-test-${each.key}-subnet"
  network       = google_compute_network.this[each.key].name
  ip_cidr_range = each.value
  region        = var.region
}

variable "region" {
  type = string
}

variable "project" {
  type = string
}

output "fw_subnets" {
  value = {
    for k, v in google_compute_subnetwork.this : k => {
      name      = v.name
      self_link = v.self_link
      cidr      = v.ip_cidr_range
      gateway   = v.gateway_address
    }
  }
}

variable "fw_networks" {
  type = map(string)
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