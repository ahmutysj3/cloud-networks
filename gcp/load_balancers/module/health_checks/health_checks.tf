resource "google_compute_region_health_check" "this" {
  name               = "${var.name_prefix}-${var.region}-health-check"
  project            = var.project
  region             = var.region
  timeout_sec        = 5
  check_interval_sec = 5

  tcp_health_check {
    port = var.port
  }
}

output "health_check" {
  description = "The created health check."
  value       = google_compute_region_health_check.this
}

variable "name_prefix" {
  description = "The prefix to use for the health check name"
  type        = string
}

variable "project" {
  description = "The project to create the health check in"
  type        = string
}

variable "region" {
  description = "The region to create the health check in"
  type        = string
}

variable "port" {
  description = "The port to use for the health check"
  type        = number
}
