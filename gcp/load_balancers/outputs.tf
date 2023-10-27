locals {
  load_balancers_outputs = { for k, v in module.load_balancers : k => v }

}

output "load_balancers" {
  value = local.load_balancers_outputs
}



/* locals {
  backend_services_outputs = { for k, v in module.load_balancers.backend_services : k => v }
  health_checks_outputs    = { for k, v in module.load_balancers.health_checks : k => v }
}
 */
