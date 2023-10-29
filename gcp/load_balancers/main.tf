locals {
  base_dir         = "./definitions"
  definition_paths = [for file in fileset(local.base_dir, "*.yaml") : "${local.base_dir}/${file}"]
  definitions      = [for definition_file in local.definition_paths : yamldecode(file(definition_file))]
  lb_params        = flatten([for v in local.definitions.*.lbs : v if v != null])
  lbs              = { for lb in local.lb_params : lb.name => lb }
}

module "load_balancers" {
  source            = "./module"
  for_each          = local.lbs
  name_prefix       = each.value.name
  region            = each.value.region
  instance_groups   = each.value.backends
  forwarding_rules  = each.value.frontends
  project           = each.value.project
  network           = each.value.network
  health_checks     = each.value.health_checks
  protocol          = each.value.protocol
  forward_all_ports = each.value.forward_all_ports
}

output "load_balancers" {
  value = { for k, v in module.load_balancers : k => v }
}

