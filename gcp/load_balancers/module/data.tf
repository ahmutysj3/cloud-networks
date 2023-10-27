locals {
  instance_groups_tuple = [for instance_group in var.instance_groups : instance_group]
  instance_groups       = { for instance_group in local.instance_groups_tuple : instance_group.instance_grp => instance_group }
}

data "google_compute_network" "this" {
  project = var.project
  name    = var.network
}