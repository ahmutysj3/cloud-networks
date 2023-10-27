locals {
  instance_groups_outputs = { for k, v in module.instance_groups : k => v }
}

output "instance_groups" {
  value = local.instance_groups_outputs
}