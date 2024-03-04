locals {
  firewall_base_dir         = "./definitions/firewalls/"
  firewall_definition_paths = [for file in fileset(local.firewall_base_dir, "*.yaml") : "${local.firewall_base_dir}/${file}"]
  firewall_definitions      = [for definition_file in local.firewall_definition_paths : yamldecode(file(definition_file))]
  firewall_params           = flatten([for params in local.firewall_definitions.*.firewall_pairs : params if params != null])
  firewalls                 = { for firewall in local.firewall_params : firewall.name_prefix => firewall if firewall.region == var.config.region }


}

module "firewalls" {
  source     = "./modules"
  for_each   = local.firewalls
  name       = each.value.name_prefix
  project_id = var.config.project_id
  region     = each.value.region
  interfaces = each.value.interfaces
  ssh_key    = try(each.value.ssh_key, "admin:${file("~/.ssh/id_rsa.pub")}")
  compute_params = {
    image_name    = each.value.image_name
    machine_type  = each.value.machine_type
    image_project = each.value.image_project
  }
  disk_params = {
    disk_size = each.value.disk_size
    disk_type = each.value.disk_type
  }
}

output "fw_ips" {
  value = module.firewalls["trace-palo-alto-test"].fw_ips
}
