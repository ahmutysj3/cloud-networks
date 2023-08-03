module "network" {
  source = "./module"
  #source = "github.com/ahmutysj3/trace-azure-tf"
  network_name = var.network_name
  supernet = var.supernet
  vnet_params = var.vnet_params
  subnet_params = var.subnet_params
  flow_logs_enable = var.flow_logs_enable
}

output "vnets" {
  value = module.network.vnets
}

output "hub_peering" {
  value = module.network.hub_peering
}

output "spokes_peering" {
  value = module.network.spokes_peering
}

output "subnets" {
  value = module.network.subnets
}

output "hub_route_tables" {
  value = module.network.hub_route_tables
}

output "spokes_route_tables" {
  value = module.network.spokes_route_tables
}


