module "network" {
  source      = "./modules/network"
  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
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
}

module "instances" {
  depends_on  = [module.network]
  source      = "./modules/instances"
  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
  web_subnets = module.network.web_subnets
  vpcs        = module.network.vpcs
  zones       = data.google_compute_zones.available.names
}

module "fortigate" {
  count                   = var.deploy_fortigate ? 1 : 0
  source                  = "./modules/fortigate"
  gcp_project             = var.gcp_project
  gcp_region              = var.gcp_region
  boot_disk_size          = 100
  subnets                 = module.network.subnets
  vpcs                    = module.network.vpcs
  hc_port                 = 443
  vpc_prod_app_cidr_range = module.network.vpc_prod_app_cidr_range
}

data "google_compute_zones" "available" {
  project = var.gcp_project
  region  = var.gcp_region
}
