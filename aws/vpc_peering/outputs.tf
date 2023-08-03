output "hub_id" {
  value = module.vpc.hub_id
}

output "hub_cidr" {
  value = module.vpc.hub_cidr
}

output "vpc_peering" {
  value = module.vpc.vpc_peering
}

output "igw" {
  value = module.vpc.igw
}

output "hub_subnets" {
  value = module.vpc.hub_subnets
}

output "vpcs" {
  value = module.vpc.vpcs
}

