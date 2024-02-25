locals {
  edge_networks = ["untrusted", "trusted"]

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
