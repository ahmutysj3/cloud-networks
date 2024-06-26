module "networks" {
  source      = "./modules/"
  fw_networks = var.fw_networks
  project     = var.config.project_id
  region      = var.config.region
  prefix      = "trace-test"
}
