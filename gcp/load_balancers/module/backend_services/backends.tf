locals {
  backend_service_name = "${var.prefix}-${var.protocol}-backend-service"
}


resource "google_compute_region_backend_service" "this" {
  name                  = local.backend_service_name
  project               = var.project
  network               = var.network
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  health_checks         = [var.health_checks]
  session_affinity      = "CLIENT_IP"
  protocol              = upper(var.protocol)

  dynamic "backend" {
    for_each = var.instance_groups
    content {
      description = "Backend for ${backend.value.name}"
      group       = backend.value.self_link
      failover    = backend.value.failover
    }
  }
}

output "backend_service" {
  value = google_compute_region_backend_service.this
}


variable "network" {
  description = "The network to create the load balancer in"
  type        = string
}

variable "protocol" {
  type        = string
  description = "Protocol for the backend service. Valid values are 'TCP', 'UDP', etc."
}

variable "project" {
  type        = string
  description = "The GCP project ID."
}

variable "prefix" {
  type        = string
  description = "Prefix used for naming resources."
}

variable "region" {
  type        = string
  description = "The GCP region."
}

variable "health_checks" {
  type        = string
  description = "The health check for the backend service."
}


variable "instance_groups" {
  type = map(object({
    failover  = bool
    name      = string
    self_link = string
  }))
}


