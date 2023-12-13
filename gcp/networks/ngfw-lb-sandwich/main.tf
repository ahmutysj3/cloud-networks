data "google_compute_zones" "available" {
  region = var.gcp_region
}

data "google_compute_default_service_account" "default" {
}

data "google_compute_image" "fortigate" {
  family  = "fortigate-74-payg"
  project = "fortigcp-project-001"
}

module "network" {
  source      = "./modules/network"
  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
  web_subnets = var.web_subnets
}

locals {
  pfsense_machine_image = "projects/terraform-project-trace-lab/global/machineImages/pfsense-full-configure-machine-image"
}

resource "google_compute_instance_from_machine_image" "pfsense" {
  depends_on           = [module.network]
  provider             = google-beta
  zone                 = data.google_compute_zones.available.names[0]
  name                 = "pfsense-active1-fw"
  source_machine_image = local.pfsense_machine_image
}

module "instances" {
  depends_on  = [module.network, google_compute_instance_from_machine_image.pfsense]
  source      = "./modules/instances"
  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
  web_subnets = var.web_subnets
  zones       = data.google_compute_zones.available.names
  vpcs        = module.network.vpcs
}

/* module "firewall" {
  source                   = "./modules/firewall"
  gcp_project              = var.gcp_project
  gcp_region               = var.gcp_region
  boot_disk_size           = var.boot_disk_size
  subnets                  = module.network.subnets
  vpcs                     = module.network.vpcs
  default_service_account  = data.google_compute_default_service_account.default.email
  zones                    = data.google_compute_zones.available.names
  image                    = data.google_compute_image.fortigate.self_link
  hc_port                  = var.hc_port
  vpc_protected_cidr_range = module.network.vpc_protected_cidr_range
} */



