locals {
  instance_groups_tuple = [for instance_group in var.instance_groups : instance_group]
  instance_groups       = { for instance_group in local.instance_groups_tuple : instance_group.instance_grp => instance_group }
}

data "google_compute_network" "this" {
  project = var.project
  name    = var.network
}

module "instance_groups" {
  source    = "./instance_groups"
  for_each  = local.instance_groups
  name      = each.value.instance_grp
  zone      = each.value.zone
  project   = var.project
  network   = data.google_compute_network.this.self_link
  instances = each.value.instances
}