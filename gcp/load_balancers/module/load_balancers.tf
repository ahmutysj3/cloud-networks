locals {
  instance_groups         = { for instance_group in var.instance_groups : instance_group.instance_grp => instance_group }
  backend_health_checks   = values({ for k, v in google_compute_region_health_check.this : v.name => v.id })
  backend_instance_groups = { for k, v in local.instance_groups_outputs : v.instance_group.name => v.instance_group.self_link }
  health_checks_tuple     = [for health_check in var.health_checks : health_check]
  health_checks           = { for health_check in var.health_checks : health_check.port_name => health_check }
  fwd_rules               = { for fwd_rule in var.fwd_rules : "${var.name_prefix}-${var.protocol}-${fwd_rule.port_range}-fwd" => fwd_rule }
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
  source          = "./backend_services"
  depends_on      = [module.instance_groups]
  prefix          = var.name_prefix
  region          = var.region
  project         = var.project
  network         = var.network
  health_checks   = local.backend_health_checks[0]
  instance_groups = local.backend_instance_groups
  protocol        = var.protocol
}

resource "google_compute_region_health_check" "this" {
  count   = length(local.health_checks)
  name    = "${var.name_prefix}-${local.health_checks_tuple[count.index].port_name}-health-check"
  project = var.project
  region  = var.region

  tcp_health_check {
    port = local.health_checks_tuple[count.index].port_number
  }
}

resource "google_compute_forwarding_rule" "this" {
  depends_on            = [module.backend_service]
  for_each              = google_compute_address.fwd_rule
  name                  = "${var.name_prefix}-${each.key}-fwd-rule"
  region                = var.region
  project               = var.project
  ip_version            = each.value.ip_version
  ip_address            = each.value.address
  subnetwork            = each.value.subnetwork
  ip_protocol           = upper(var.protocol)
  backend_service       = module.backend_service.backend_service.self_link
  load_balancing_scheme = "INTERNAL"
  all_ports             = var.all_ports
  ports                 = var.all_ports ? null : [lookup(local.fwd_rule_ports, each.key, null)]
}

locals {
  fwd_rule_ports = { for k, v in local.fwd_rules : k => v.port_range }
}

resource "google_compute_address" "fwd_rule" {
  for_each     = local.fwd_rules
  address_type = "INTERNAL"
  name         = "${each.key}-fwd-ip"
  ip_version   = "IPV4"
  project      = var.project
  region       = var.region
  address      = each.value.ip_address
  subnetwork   = data.google_compute_subnetwork.this[each.key].self_link
}

data "google_compute_subnetwork" "this" {
  for_each = local.fwd_rules
  project  = var.project
  region   = var.region
  name     = each.value.subnet
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

variable "all_ports" {}

locals {
  instance_groups_outputs  = { for k, v in module.instance_groups : k => v }
  backend_services_outputs = { for k, v in module.backend_service : k => v }
  health_checks_outputs    = google_compute_region_health_check.this
}

output "instance_groups" {
  value = local.instance_groups_outputs
}

output "backend_services" {
  value = local.backend_services_outputs
}

output "backend_health_checks" {
  value = local.health_checks_outputs
}

output "fwd_rules" {
  value = local.fwd_rules

}
