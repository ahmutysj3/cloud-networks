locals {
  instance_groups         = { for instance_group in var.instance_groups : instance_group.instance_grp => instance_group }
  backend_instance_groups = { for k, v in module.instance_groups : k => v.backend_ig_values }
  lb_name_prefix          = "${var.name_prefix}-${var.protocol}"
}

module "health_checks" {
  source      = "./health_checks"
  name_prefix = var.name_prefix
  project     = var.project
  region      = var.region
  port        = var.tcp_health_check_port
}

module "instance_groups" {
  source    = "./instance_groups"
  for_each  = local.instance_groups
  name      = each.value.instance_grp
  zone      = each.value.zone
  failover  = each.value.failover
  project   = var.project
  network   = var.network
  instances = each.value.instances
}

module "backend_service" {
  source          = "./backend_services"
  name_prefix     = local.lb_name_prefix
  region          = var.region
  project         = var.project
  network         = var.network
  health_check    = module.health_checks.health_check.self_link
  instance_groups = local.backend_instance_groups
  protocol        = var.protocol

}

module "forwarding_rules" {
  source                    = "./forwarding_rules"
  for_each                  = { for k, v in var.forwarding_rules : k => v }
  name_prefix               = local.lb_name_prefix
  region                    = var.region
  network                   = var.network
  project                   = var.project
  protocol                  = var.protocol
  forward_all_ports         = var.forward_all_ports
  index                     = each.key
  fwd_rule                  = each.value
  backend_service_self_link = module.backend_service.backend_service.self_link
}

variable "name_prefix" {
  description = "The prefix to use for the load balancer name"
  type        = string
}

variable "region" {
  description = "The region to create the load balancer in"
  type        = string

}

variable "instance_groups" {
  description = "The instance groups to use for the load balancer"
  type = list(object({
    instance_grp = string
    zone         = string
    failover     = bool
    instances    = list(string)
  }))
}

variable "network" {
  description = "The network to create the load balancer in"
  type        = string
}

variable "project" {
  description = "The project to create the load balancer in"
  type        = string
}

variable "tcp_health_check_port" {
  description = "The health check port to use for the load balancer"
  type        = number
}

variable "protocol" {
  description = "The protocol to use for the load balancer"
  type        = string
  validation {
    condition     = can(regex("(?i)^(udp|tcp)$", var.protocol))
    error_message = "The protocol must be either 'tcp' or 'udp'."
  }
}

variable "forwarding_rules" {
  description = "The forwarding rules to create for the load balancer"
  type = list(object({
    ports      = number
    ip_address = string
    subnet     = string
  }))
}

variable "forward_all_ports" {
  description = "Whether to forward all ports to the backend service"
  type        = bool
}

