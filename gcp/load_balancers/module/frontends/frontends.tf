resource "google_compute_forwarding_rule" "this" {
  depends_on = [module.backend_service]
  for_each   = var.fwd_rules
  name       = each.key
  region     = var.region
  project    = var.project

  load_balancing_scheme = "INTERNAL"
  ip_version            = google_compute_address.fwd_rule[each.key].ip_version
  ip_address            = google_compute_address.fwd_rule[each.key].address
  ip_protocol           = upper(var.protocol)
  subnetwork            = google_compute_address.fwd_rule[each.key].subnetwork
  backend_service       = module.backend_service.backend_service.self_link
  all_ports             = var.all_ports

  ports = var.all_ports ? null : [each.value.port_range]
}

locals {
  fwd_rule_ports = { for k, v in var.fwd_rules : k => v.port_range }
}

resource "google_compute_address" "fwd_rule" {
  address_type = "INTERNAL"
  name         = "${each.key}-fwd-ip"
  ip_version   = "IPV4"
  project      = var.project
  region       = var.region
  address      = each.value.ip_address
  subnetwork   = data.google_compute_subnetwork.this[each.key].self_link
}

data "google_compute_subnetwork" "this" {
  project = var.project
  region  = var.region
  name    = var.fwd_rules.subnet
}

variable "network" {}
variable "project" {}
variable "prefix" {}
variable "region" {}
variable "protocol" {}
variable "all_ports" {}
variable "fwd_rules" {}
