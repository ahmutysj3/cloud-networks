locals {
  instance_groups_tuple = [for instance_group in var.instance_groups : instance_group]
  instance_groups       = { for instance_group in local.instance_groups_tuple : instance_group.instance_grp => instance_group }

  health_checks_tuple = [for health_check in var.health_checks : health_check]
  health_checks       = { for health_check in local.health_checks_tuple : health_check.port_name => health_check }
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

module "backend_service" {
  source = "./backend_services"
}

module "health_checks" {
  source  = "./health_checks"
  for_each = local.health_checks
  prefix = var.name_prefix
  region        = var.region
  port_name      = each.value.port_name
  port_number    = each.value.port_number
  project = var.project
}

data "google_compute_network" "this" {
  project = var.project
  name    = var.network
}

variable "name_prefix" {}

variable "region" {}

variable "instance_groups" {}

variable "network" {}

variable "project" {}

variable "health_checks" {}