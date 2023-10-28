resource "google_compute_region_backend_service" "this" {
  name                  = "${var.prefix}-${var.protocol}-backend-service"
  project               = var.project
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  health_checks         = [var.health_checks]
  session_affinity      = "CLIENT_IP"
  protocol              = upper(var.protocol)

  dynamic "backend" {
    for_each = var.instance_groups
    content {
      group    = backend.value.backend_instance_group.self_link
      failover = backend.value.backend_instance_group.failover
    }
  }
}

output "backend_service" {
  value = google_compute_region_backend_service.this
}

variable "protocol" {}
variable "network" {}
variable "project" {}
variable "prefix" {}
variable "region" {}
variable "health_checks" {}
variable "instance_groups" {}

