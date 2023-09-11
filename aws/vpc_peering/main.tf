module "vpc" {
  source        = "./network"
  vpcs          = var.vpcs
  spoke_subnets = var.spoke_subnets
}