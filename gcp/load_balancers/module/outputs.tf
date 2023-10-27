locals {
  instance_groups_outputs = { for k, v in module.instance_groups : k => v }
}

output "instance_groups" {
  value = local.instance_groups_outputs
}

locals {
  health_checks_outputs = { for k, v in module.health_checks : k => v }
}

output "health_checks" {
  value = local.health_checks_outputs
}