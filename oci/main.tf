module "network" {
  source = "./network"

  # General OCI Parameters
  region_pri       = "us-ashburn-1"
  main_compartment = var.main_compartment

  # Network Params
  dc_name       = "trace"
  supernet_cidr = "10.1.0.0/16"

  # Hub VCN Params - subnets auto-configured
  hub_vcn_cidr = "10.1.1.0/24"
  deploy_fw    = false

  # Spoke VCN Params
  spoke_vcns    = var.spoke_vcns
  spoke_subnets = var.spoke_subnets
  nsg_params    = var.nsg_params

}
