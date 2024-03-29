data "google_compute_network" "this" {
  depends_on = [module.edge_network_services]
  project    = var.edge_project
  for_each   = toset(local.fw_edge_networks)
  name       = "${each.value}-vpc"
}

data "google_compute_subnetwork" "this" {
  depends_on = [module.edge_network_services]
  project    = var.edge_project
  region     = var.gcp_region
  for_each   = toset(local.fw_edge_networks)
  name       = "${each.value}-subnet"
}

locals {
  fw_networks = { for k, v in data.google_compute_network.this : k => v.name }
  fw_subnets  = { for k, v in data.google_compute_subnetwork.this : k => v.self_link }
  fw_ip_addr  = { for k, v in data.google_compute_subnetwork.this : k => cidrhost(v.ip_cidr_range, 2) }
  fw_gateway  = { for k, v in data.google_compute_subnetwork.this : k => v.gateway_address }

  fw_edge_networks = ["untrusted", "mgmt", "ha", "trusted"]
  fw_network_interfaces = [for networks in local.fw_edge_networks : {
    vpc     = local.fw_networks[networks]
    subnet  = local.fw_subnets[networks]
    ip_addr = local.fw_ip_addr[networks]
    gateway = local.fw_gateway[networks]
  }]

  firewall_model = "palo-alto" # "fortigate", "pfsense", "palo-alto"

}

module "firewall" {
  depends_on = [module.edge_network_services, module.spoke_vpcs]
  source     = "./modules/edge-firewall"
  model      = "palo-alto" # fortigate, pfsense, palo-alto
  providers = {
    google      = google.edge
    google-beta = google-beta.edge
  }
  fw_network_interfaces = local.fw_network_interfaces
  gui_port              = 443
  ssh_public_key        = var.trace_ssh_public_key
  fw_public_interface   = var.fw_public_interface
}

