resource "google_compute_forwarding_rule" "this" {
  name                  = var.forward_all_ports ? "${var.name_prefix}-${var.protocol}-all-ports-fwd-rule" : local.fwd_rule_name
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



resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
}

resource "google_compute_address" "fwd_rule" {
  address_type = "INTERNAL"
  name         = "${var.name_prefix}-${random_string.random.result}-ip"
  ip_version   = "IPV4"
  project      = var.project
  region       = var.region
  address      = var.fwd_rule.ip_address
  subnetwork   = data.google_compute_subnetwork.this.self_link
}

locals {
  fwd_rule_name = "${substr(google_compute_address.fwd_rule.name, 0, length(google_compute_address.fwd_rule.name) - 2)}-fwd-rule"
}

data "google_compute_subnetwork" "this" {
  project = var.project
  region  = var.region
  name    = var.fwd_rule.subnet
}

variable "name_prefix" {}
variable "project" {}
variable "region" {}
variable "protocol" {}
variable "forward_all_ports" {}
variable "fwd_rule" {}
variable "backend_service_self_link" {}


