data "google_compute_instance" "instance_group" {
  for_each = toset(var.instances)
  project  = var.project
  zone     = var.zone
  name     = each.key
}

resource "google_compute_instance_group" "this" {
  name      = var.name
  zone      = var.zone
  project   = var.project
  network   = var.network
  instances = [for instance in data.google_compute_instance.instance_group : instance.self_link]
}

output "instance_group" {
  value = google_compute_instance_group.this
}

output "backend_instance_group" {
  value = local.backend_ig_values
}

locals {
  backend_ig_values = {
    self_link = google_compute_instance_group.this.self_link
    name      = google_compute_instance_group.this.name
    failover  = var.failover
  }
}
variable "name" {}
variable "zone" {}
variable "project" {}
variable "network" {}
variable "instances" {}
variable "failover" {}

