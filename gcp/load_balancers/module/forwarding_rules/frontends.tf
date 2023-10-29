locals {
  forwarding_rule_name = "${var.name_prefix}-fwd-rule-${var.index}"
  ip_address_name      = "${var.name_prefix}-fwd-rule-ip-${var.index}"
}

resource "google_compute_forwarding_rule" "this" {
  name                  = local.forwarding_rule_name
  region                = var.region
  project               = var.project
  load_balancing_scheme = google_compute_address.this.address_type
  ip_version            = google_compute_address.this.ip_version
  ip_address            = google_compute_address.this.address
  ip_protocol           = upper(var.protocol)
  subnetwork            = google_compute_address.this.subnetwork
  network               = data.google_compute_network.this.self_link
  backend_service       = var.backend_service_self_link
  all_ports             = var.forward_all_ports
  ports                 = var.forward_all_ports ? null : [var.fwd_rule.ports]
}

resource "google_compute_address" "this" {
  name         = local.ip_address_name
  address_type = "INTERNAL"
  ip_version   = "IPV4"
  project      = var.project
  region       = var.region
  address      = var.fwd_rule.ip_address
  subnetwork   = data.google_compute_subnetwork.this.self_link
}

data "google_compute_subnetwork" "this" {
  project = var.project
  region  = var.region
  name    = var.fwd_rule.subnet
}

data "google_compute_network" "this" {
  project = var.project
  name    = var.network
}

output "forwarding_rule" {
  description = "The created forwarding rule."
  value       = google_compute_forwarding_rule.this
}

output "google_compute_address" {
  description = "The allocated frontend IP address."
  value       = google_compute_address.this
}

variable "network" {
  description = "The network to create the forwarding rule and forwarding IP in."
  type        = string
}

variable "project" {
  type        = string
  description = "The GCP project ID."
}

variable "region" {
  type        = string
  description = "The GCP region."
}

variable "protocol" {
  type        = string
  description = "Protocol for the forwarding rule. Valid values are 'tcp' or 'udp'"
  validation {
    condition     = can(regex("(?i)^(udp|tcp)$", var.protocol))
    error_message = "The protocol must be either 'tcp' or 'udp'."
  }
}

variable "forward_all_ports" {
  type        = bool
  description = "A boolean that indicates if all ports should be forwarded."
}

variable "fwd_rule" {
  type = object({
    ip_address = string
    subnet     = string
    ports      = string
  })
  description = "A map containing forwarding rule configuration."
}

variable "backend_service_self_link" {
  type        = string
  description = "The self-link of the backend service."
}

variable "name_prefix" {
  type        = string
  description = "Optional: A prefix used for naming forwarding rule resources."
}

variable "index" {
  type        = string
  description = "value of the index"
}
