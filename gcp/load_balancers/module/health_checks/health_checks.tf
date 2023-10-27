resource "google_compute_region_health_check" "tcp" {
  name    = "${var.prefix}-${var.port_name}-health-check"
  project = var.project
  region  = var.region

  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = var.port_number
  }
}

variable "region" {}
variable "port_number" {}
variable "port_name" {}
variable "project" {}
variable "prefix" {}

output "health_check" {
  value = google_compute_region_health_check.tcp
}
