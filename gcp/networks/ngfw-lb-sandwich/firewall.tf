data "google_compute_network" "this" {
  project  = var.edge_project
  for_each = toset(local.edge_networks)
  name     = "${each.value}-vpc"
}

data "google_compute_subnetwork" "this" {
  project  = var.edge_project
  region   = var.gcp_region
  for_each = toset(local.edge_networks)
  name     = "${each.value}-subnet"
}

locals {
  fw_networks = { for k, v in data.google_compute_network.this : k => v.name }
  fw_subnets  = { for k, v in data.google_compute_subnetwork.this : k => v.self_link }
  fw_ip_addr  = { for k, v in data.google_compute_subnetwork.this : k => cidrhost(v.ip_cidr_range, 2) }
  fw_gateway  = { for k, v in data.google_compute_subnetwork.this : k => v.gateway_address }

  fw_network_interfaces = [for networks in local.edge_networks : {
    vpc     = local.fw_networks[networks]
    subnet  = local.fw_subnets[networks]
    ip_addr = local.fw_ip_addr[networks]
    gateway = local.fw_gateway[networks]
  }]
}

module "firewall" {
  depends_on = [module.edge_network_services]
  source     = "./modules/edge-firewall"
  model      = "palo-alto" # fortigate, pfsense, palo-alto
  providers = {
    google      = google.edge
    google-beta = google-beta.edge
  }
  fw_network_interfaces = local.fw_network_interfaces
  gui_port              = 8001
  ssh_public_key        = var.trace_ssh_public_key
}

