locals {
  load_balancers_outputs = { for k, v in module.load_balancers : k => v }
}

output "load_balancers" {
  value = local.load_balancers_outputs
}