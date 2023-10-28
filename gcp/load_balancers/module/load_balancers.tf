locals {
  instance_groups = { for instance_group in var.instance_groups : instance_group.instance_grp => instance_group }

  backend_igs = { for k, v in module.instance_groups : k => v }

  health_checks         = [for health_check in var.health_checks : health_check]
  backend_health_checks = values({ for k, v in google_compute_region_health_check.this : v.name => v.id })

  fwd_rules = { for fwd_rule in var.fwd_rules : var.forward_all_ports ? "${var.name_prefix}-${var.protocol}-all-ports" : "${var.name_prefix}-${var.protocol}-${fwd_rule.ports}" => fwd_rule }

  test_fwd_rules = { for fwd_rule in var.fwd_rules : var.forward_all_ports ? "${local.fwd_name_prefix}-all-ports" : "${local.fwd_name_prefix}-${fwd_rule.ports}" => fwd_rule }

  fwd_name_prefix = "${var.name_prefix}-${var.protocol}"
}

module "instance_groups" {
  source    = "./instance_groups"
  for_each  = local.instance_groups
  name      = each.value.instance_grp
  zone      = each.value.zone
  failover  = each.value.failover
  project   = var.project
  network   = data.google_compute_network.this.self_link
  instances = each.value.instances
}

module "backend_service" {
  source          = "./backend_services"
  depends_on      = [module.instance_groups]
  prefix          = var.name_prefix
  region          = var.region
  project         = var.project
  network         = var.network
  health_checks   = local.backend_health_checks[0]
  instance_groups = local.backend_igs
  protocol        = var.protocol
}

module "forwarding_rules" {
  source                    = "./frontends"
  for_each                  = local.test_fwd_rules
  name_prefix               = var.name_prefix
  region                    = var.region
  project                   = var.project
  protocol                  = var.protocol
  forward_all_ports         = var.forward_all_ports
  prefix                    = each.key
  fwd_rule                  = each.value
  backend_service_self_link = module.backend_service.backend_service.self_link
}


resource "google_compute_region_health_check" "this" {
  count   = length(local.health_checks)
  name    = "${var.name_prefix}-${local.health_checks[count.index].port_name}-health-check"
  project = var.project
  region  = var.region

  tcp_health_check {
    port = local.health_checks[count.index].port_number
  }
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

variable "protocol" {}

variable "fwd_rules" {}

variable "forward_all_ports" {}
