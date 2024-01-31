data "google_compute_instance" "this" {
  project = var.vm_project
  zone    = var.vm_zone
  name    = var.instance_name
}

data "google_compute_zones" "this" {
  region = var.gcp_region
}
data "google_compute_network" "this" {
  project = var.network_project
  name    = var.vpc_name
}

variable "vm_project" {
  description = "The project to create the instance in"
  type        = string

}

variable "vm_zone" {
  description = "The zone to create the instance in"
  type        = string
}

variable "instance_name" {
  description = "The name of the instance"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC to use for the instance."
  type        = string
}

variable "network_project" {
  description = "The project to create the instance in"
  type        = string

}

variable "gcp_region" {
  description = "The region to create the instance in"
  type        = string
}

variable "lb_name" {
  description = "The name of the load balancer"
  type        = string
}

variable "name_prefix" {
  type    = string
  default = "trace"
}

locals {
  resources = ["fwd_rule"]
  names     = { for k, v in local.resources : k => "${var.name_prefix}-${k}" }
}
resource "google_compute_forwarding_rule" "this" {
  provider = google-beta
  name     = local.names["fwd_rule"]
  region   = var.gcp_region

  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.default.id
  network               = google_compute_network.default.id
  subnetwork            = google_compute_subnetwork.default.id
  network_tier          = "PREMIUM"
}
