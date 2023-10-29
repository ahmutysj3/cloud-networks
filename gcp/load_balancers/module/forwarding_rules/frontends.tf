locals {
  forwarding_rule_name = "${var.prefix}-fwd-rule"
  ip_address_name      = "${var.prefix}-fwd-ip"
}

resource "google_compute_forwarding_rule" "this" {
  name                  = local.forwarding_rule_name
  region                = var.region
  project               = var.project
  load_balancing_scheme = "INTERNAL"
  ip_version            = google_compute_address.this.ip_version
  ip_address            = google_compute_address.this.address
  ip_protocol           = upper(var.protocol)
  subnetwork            = google_compute_address.this.subnetwork
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

output "forwarding_rule" {
  description = "The created forwarding rule."
  value       = google_compute_forwarding_rule.this
}

output "frontend_ip_address" {
  description = "The allocated frontend IP address."
  value       = google_compute_address.this.address
}

variable "prefix" {
  type        = string
  description = "Prefix used for naming resources."
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
  description = "The protocol used by the forwarding rule. Valid values are 'TCP' and 'UDP'."
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
  default     = ""
}
