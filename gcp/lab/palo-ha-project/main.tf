module "networks" {
  source   = "./modules/networks"
  fw_networks = var.fw_networks
  project  = var.config.project_id
  region   = var.config.region
}

locals {
    firewall_base_dir         = "./definitions/firewalls/"
    firewall_definition_paths = [for file in fileset(local.firewall_base_dir, "*.yaml") : "${local.firewall_base_dir}/${file}"]
    firewall_definitions      = [for definition_file in local.firewall_definition_paths : yamldecode(file(definition_file))]
    firewall_params           = flatten([for params in local.firewall_definitions.*.firewall_pairs : params if params != null])
    firewalls                 = { for firewall in local.firewall_params : firewall.name_prefix => firewall if firewall.region == var.config.region }
}