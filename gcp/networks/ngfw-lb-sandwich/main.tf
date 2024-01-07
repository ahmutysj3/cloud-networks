locals {
  edge_networks = ["untrusted", "trusted"]

  fw_network_interfaces = [for type in local.edge_networks : {
    vpc     = module.edge_network_services[type].network
    subnet  = module.edge_network_services[type].subnet
    ip_addr = module.edge_network_services[type].ip_addr
    gateway = module.edge_network_services[type].gateway
  }]

  peer_vpcs = { for vpcs, spoke in module.spoke_vpcs : vpcs => spoke.network }
}

module "spoke_vpcs" {
  source        = "./modules/app-networks"
  for_each      = var.spoke_vpcs
  ip_block      = each.value.cidr
  project       = each.value.project
  vpc_name      = "${each.key}-vpc"
  spoke_subnets = var.spoke_subnets
  region        = var.gcp_region

  providers = {
    google      = google.spoke
    google-beta = google-beta.spoke
  }
}

module "edge_network_services" {
  source     = "./modules/edge-network"
  for_each   = var.edge_vpcs
  ip_block   = each.value.cidr
  router     = each.value.router
  vpc        = each.key
  spoke_vpcs = local.peer_vpcs
  providers = {
    google      = google.edge
    google-beta = google-beta.edge
  }
}

module "firewall" {
  depends_on = [module.edge_network_services]
  source     = "./modules/edge-firewall"
  model      = "pfsense"
  providers = {
    google      = google.edge
    google-beta = google-beta.edge
  }
  fw_network_interfaces = local.fw_network_interfaces
  gui_port              = 8001
  ssh_public_key        = var.trace_ssh_public_key
}

