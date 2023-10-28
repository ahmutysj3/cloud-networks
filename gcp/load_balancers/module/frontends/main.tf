resource "google_compute_forwarding_rule" "this" {
  name                  = var.forward_all_ports ? "${var.name_prefix}-${var.protocol}-all-ports-fwd-rule" : "${var.prefix}-rule"
  region                = var.region
  project               = var.project
  load_balancing_scheme = "INTERNAL"
  ip_version            = google_compute_address.fwd_rule.ip_version
  ip_address            = google_compute_address.fwd_rule.address
  ip_protocol           = upper(var.protocol)
  subnetwork            = google_compute_address.fwd_rule.subnetwork
  backend_service       = var.backend_service_self_link
  all_ports             = var.forward_all_ports
  ports                 = var.forward_all_ports ? null : [var.fwd_rule.ports]
}

output "forwarding_rules" {
  value = google_compute_forwarding_rule.this
}

resource "google_compute_address" "fwd_rule" {
  address_type = "INTERNAL"
  name         = "${var.prefix}-ip"
  ip_version   = "IPV4"
  project      = var.project
  region       = var.region
  address      = var.fwd_rule.ip_address
  subnetwork   = data.google_compute_subnetwork.this.self_link
}

output "ip_address" {
  value = google_compute_address.fwd_rule
}

data "google_compute_subnetwork" "this" {
  project = var.project
  region  = var.region
  name    = var.fwd_rule.subnet
}

variable "prefix" {}
variable "name_prefix" {}
variable "project" {}
variable "region" {}
variable "protocol" {}
variable "forward_all_ports" {}
variable "fwd_rule" {}
variable "backend_service_self_link" {}


