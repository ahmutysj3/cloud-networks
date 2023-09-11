module "vpc" {
  source        = "./network"
  vpcs          = var.vpcs
  spoke_subnets = var.spoke_subnets
}

data "vault_aws_access_credentials" "creds" {
  backend = "aws"
  role    = "terraform-user"
}