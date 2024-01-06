/* module "network" {
  source = "./modules/network"
  web_subnets = [
    "rick",
    "birdperson",
    "squanchy",
    "morty"
  ]
  default_fw_route      = true
  deploy_pfsense        = true
  pfsense_name          = "pfsense-active-fw"
  pfsense_machine_image = "pfsense-full-configure"
  ilb_next_hop          = true
  hc_port               = 443
  vpcs                  = var.vpcs
  zones                 = data.google_compute_zones.available.names
  image_project         = var.image_project
}

module "instances" {
  depends_on  = [module.network]
  source      = "./modules/instances"
  project     = var.bu1_project
  web_subnets = module.network.web_subnets
  vpcs        = module.network.vpcs
  zones       = data.google_compute_zones.available.names
}

module "fortigate" {
  count                   = var.deploy_fortigate ? 1 : 0
  source                  = "./modules/fortigate"
  project                 = var.edge_project
  region                  = var.gcp_region
  boot_disk_size          = 100
  subnets                 = module.network.subnets
  vpcs                    = module.network.vpcs
  hc_port                 = 443
  vpc_prod_app_cidr_range = module.network.vpc_prod_app_cidr_range
}

module "certs" {
  source = "./modules/certs"
}
*/

module "edge_network_services" {
  source   = "./modules/edge-network"
  for_each = var.edge_vpcs
  ip_block = each.value.cidr
  project  = each.value.project
  router   = each.value.router
  vpc      = each.key
  providers = {
    google      = google.edge
    google-beta = google-beta.edge
  }
}
