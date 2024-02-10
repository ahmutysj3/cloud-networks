module "gcp_instances" {
  source          = "./modules"
  gcp_region      = var.gcp_region
  instance_name   = var.instance_name
  machine_type    = var.machine_type
  tags            = var.tags
  network_project = var.network_project
  vpc_name        = var.vpc_name
  subnetwork_name = var.subnetwork_name
  allow_all       = var.allow_all
}
