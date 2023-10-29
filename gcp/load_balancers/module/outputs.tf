locals {
  instance_groups_outputs     = { for k, v in module.instance_groups : k => v.instance_group }
  frontend_ip_address_outputs = { for k, v in module.forwarding_rules : k => v.frontend_ip_address }
  forwarding_rules_outputs    = { for k, v in module.forwarding_rules : k => v.forwarding_rule }
  backend_services_outputs    = { for k, v in module.backend_service : k => v }
  health_checks_outputs       = { for k, v in module.health_checks : k => v }
}

output "instance_groups" {
  value = local.instance_groups_outputs
}

output "backend_services" {
  value = local.backend_services_outputs
}

output "tcp_health_checks" {
  value = local.health_checks_outputs
}

output "forwarding_rules" {
  value = local.forwarding_rules_outputs
}

output "frontend_ip_address" {
  value = local.frontend_ip_address_outputs
}
