module "networks" {
  source   = "./modules/networks"
  fw_networks = var.fw_networks
  project  = var.config.project_id
  region   = var.config.region
}