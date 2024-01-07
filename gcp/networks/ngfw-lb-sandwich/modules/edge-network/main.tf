locals {
  default_fw_rules = ["ingress", "egress"]
}

data "google_compute_zones" "available" {
  project = data.google_client_config.this.project
  region  = data.google_client_config.this.region
}

data "google_client_config" "this" {
}

module "cloud_router" {
  source   = "./cloud-router"
  count    = var.router ? 1 : 0
  vpc_name = var.vpc
  network  = google_compute_network.this.name
}

module "peerings" {
  source              = "./peerings"
  for_each            = { for k, v in var.spoke_vpcs : k => v if var.vpc == "trusted" }
  hub_vpc_name        = google_compute_network.this.name
  hub_vpc_self_link   = google_compute_network.this.self_link
  spoke_vpc_name      = each.key
  spoke_vpc_self_link = each.value
}

resource "google_compute_network" "this" {
  provider                        = google
  name                            = "${var.vpc}-vpc"
  project                         = data.google_client_config.this.project
  auto_create_subnetworks         = false
  delete_default_routes_on_create = var.vpc == "untrusted" ? false : true
}

resource "google_compute_subnetwork" "this" {
  provider      = google
  project       = data.google_client_config.this.project
  name          = "${var.vpc}-subnet"
  ip_cidr_range = var.ip_block
  region        = data.google_client_config.this.region
  network       = google_compute_network.this.name
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}

resource "google_compute_firewall" "this" {
  count              = length(local.default_fw_rules)
  provider           = google
  name               = "default-allow-all-${local.default_fw_rules[count.index]}-${var.vpc}"
  project            = data.google_client_config.this.project
  network            = google_compute_network.this.name
  priority           = 1000
  direction          = upper(local.default_fw_rules[count.index])
  destination_ranges = count.index == 0 ? null : ["0.0.0.0/0"]
  source_ranges      = count.index == 0 ? ["0.0.0.0/0"] : null

  allow {
    protocol = "all"
  }
  target_tags = ["firewall"]
}




