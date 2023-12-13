module "network" {
  source                = "./modules/network"
  gcp_project           = var.gcp_project
  gcp_region            = var.gcp_region
  web_subnets           = var.web_subnets
  default_fw_route      = var.default_fw_route
  deploy_pfsense        = var.deploy_pfsense
  pfsense_name          = var.pfsense_name
  pfsense_machine_image = var.pfsense_machine_image
}

module "instances" {
  depends_on  = [module.network]
  source      = "./modules/instances"
  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
  web_subnets = var.web_subnets
  vpcs        = module.network.vpcs
}

module "fortigate" {
  count                    = var.deploy_fortigate ? 1 : 0
  source                   = "./modules/fortigate"
  gcp_project              = var.gcp_project
  gcp_region               = var.gcp_region
  boot_disk_size           = var.boot_disk_size
  subnets                  = module.network.subnets
  vpcs                     = module.network.vpcs
  hc_port                  = var.hc_port
  vpc_protected_cidr_range = module.network.vpc_protected_cidr_range
}



