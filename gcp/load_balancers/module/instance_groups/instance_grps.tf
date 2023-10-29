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

locals {
  backend_ig_values = {
    self_link = google_compute_instance_group.this.self_link
    name      = google_compute_instance_group.this.name
    failover  = var.failover
  }
}

output "instance_group" {
  description = "The created instance group."
  value       = google_compute_instance_group.this
}

output "backend_instance_group" {
  description = "Values for backend instance group."
  value       = local.backend_ig_values
}

variable "name" {
  type        = string
  description = "The name of the instance group."
}

variable "zone" {
  type        = string
  description = "The GCP zone where the instance group is created."
}

variable "project" {
  type        = string
  description = "The GCP project ID."
}

variable "network" {
  type        = string
  description = "The network to which the instance group is attached."
}

variable "instances" {
  type        = list(string)
  description = "List of instances to be attached to the instance group."
}

variable "failover" {
  type        = bool
  description = "Boolean indicating if failover is enabled."
}
