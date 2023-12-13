module "pfsense" {
  source                = "./modules/pfsense"
  pfsense_machine_image = var.pfsense_machine_image
  pfsense_name          = var.pfsense_name
  gcp_project           = var.gcp_project
  gcp_region            = var.gcp_region
  wan_nic_ip            = cidrhost(module.network.subnets["untrusted-subnet"].ip_cidr_range, 2)
  lan_nic_ip            = cidrhost(module.network.subnets["trusted-subnet"].ip_cidr_range, 2)
  wan_subnet            = module.network.subnets["untrusted-subnet"].self_link
  lan_subnet            = module.network.subnets["trusted-subnet"].self_link
}

module "network" {
  source      = "./modules/network"
  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
  web_subnets = var.web_subnets
}


module "instances" {
  depends_on  = [module.network]
  source      = "./modules/instances"
  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
  web_subnets = var.web_subnets
  zones       = data.google_compute_zones.available.names
  vpcs        = module.network.vpcs
}

/* module "fortigate" {
  source                   = "./modules/fortigate"
  gcp_project              = var.gcp_project
  gcp_region               = var.gcp_region
  boot_disk_size           = var.boot_disk_size
  subnets                  = module.network.subnets
  vpcs                     = module.network.vpcs
  hc_port                  = var.hc_port
  vpc_protected_cidr_range = module.network.vpc_protected_cidr_range
} */



