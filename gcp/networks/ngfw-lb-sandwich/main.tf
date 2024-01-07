locals {
  edge_networks = ["untrusted", "trusted"]

  fw_network_interfaces = [for type in local.edge_networks : {
    vpc     = module.edge_network_services[type].network
    subnet  = module.edge_network_services[type].subnet
    ip_addr = module.edge_network_services[type].ip_addr
    gateway = module.edge_network_services[type].gateway
  }]
}

module "spoke_vpc_prod" {
  source        = "./modules/app-networks"
  ip_block      = var.spoke_vpcs["prod"].cidr
  project       = var.spoke_vpcs["prod"].project
  vpc_name      = "prod-vpc"
  spoke_subnets = var.spoke_subnets
  region        = var.gcp_region

  providers = {
    google      = google.spoke1
    google-beta = google-beta.spoke1
  }
}

module "spoke_vpc_dev" {
  source        = "./modules/app-networks"
  ip_block      = var.spoke_vpcs["dev"].cidr
  project       = var.spoke_vpcs["dev"].project
  vpc_name      = "dev-vpc"
  spoke_subnets = var.spoke_subnets
  region        = var.gcp_region

  providers = {
    google      = google.spoke2
    google-beta = google-beta.spoke2
  }
}

module "edge_network_services" {
  source     = "./modules/edge-network"
  for_each   = var.edge_vpcs
  ip_block   = each.value.cidr
  router     = each.value.router
  vpc        = each.key
  spoke_vpcs = merge(module.spoke_vpc_prod.network, module.spoke_vpc_dev.network)
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

  ssh_public_key = var.trace_ssh_public_key
}

