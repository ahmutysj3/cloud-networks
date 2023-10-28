locals {
  instance_groups_outputs  = { for k, v in module.instance_groups : k => v.instance_group }
  fwd_rules_outputs        = { for k, v in module.forwarding_rules : k => v }
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

output "forwarding_rules" {
  value = local.fwd_rules_outputs

}
