locals {
  fw_vnics = { for index, interface in flatten([
    for count, values in var.interfaces : [
      for interface, details in values : {
        "index"          = count
        "interface"      = interface
        "public_ip"      = details.public_ip
        "subnet"         = details.subnet
        "subnet_project" = details.subnet_project
      }
    ]
    ]) : index => {
    "interface"      = interface.interface
    "public_ip"      = interface.public_ip
    "subnet"         = interface.subnet
    "subnet_project" = interface.subnet_project
  } }

}

data "google_compute_subnetwork" "this" {
  for_each = local.fw_vnics
  project  = each.value.subnet_project
  region   = var.region
  name     = each.value.subnet
}


module "fw_instances" {
  source       = "./vms"
  count        = 2
  fw_vnics     = local.fw_vnics
  fw_subnets   = data.google_compute_subnetwork.this
  project_id   = var.project_id
  region       = var.region
  ssh_key      = var.ssh_key
  name         = var.name
  index        = count.index
  image       = var.compute_params.image_name
  machine_type = var.compute_params.machine_type
  disk_params  = var.disk_params
}

module "bootstrap" {
  source = "./bootstrap"
  
}

/* locals {
    vmseries_vms = {
      vmseries01 = {
        zone                      = data.google_compute_zones.available.names[0]
        management_private_ip     = cidrhost(var.cidr_mgmt, 2)
        managementpeer_private_ip = cidrhost(var.cidr_mgmt, 3)
        untrust_private_ip        = cidrhost(var.cidr_untrust, 2)
        untrust_gateway_ip        = data.google_compute_subnetwork.untrust.gateway_address
        trust_private_ip          = cidrhost(var.cidr_trust, 2)
        trust_gateway_ip          = data.google_compute_subnetwork.trust.gateway_address
        ha2_private_ip            = cidrhost(var.cidr_ha2, 2)
        ha2_subnet_mask           = cidrnetmask(var.cidr_ha2)
        ha2_gateway_ip            = data.google_compute_subnetwork.ha2.gateway_address
        external_lb_ip            = google_compute_address.external_nat_ip.address
        workload_vm               = cidrhost(var.cidr_trust, 5)
      }

      vmseries02 = {
        zone                      = data.google_compute_zones.available.names[1]
        management_private_ip     = cidrhost(var.cidr_mgmt, 3)
        managementpeer_private_ip = cidrhost(var.cidr_mgmt, 2)
        untrust_private_ip        = cidrhost(var.cidr_untrust, 3)
        untrust_gateway_ip        = data.google_compute_subnetwork.untrust.gateway_address
        trust_private_ip          = cidrhost(var.cidr_trust, 3)
        trust_gateway_ip          = data.google_compute_subnetwork.trust.gateway_address
        ha2_private_ip            = cidrhost(var.cidr_ha2, 3)
        ha2_subnet_mask           = cidrnetmask(var.cidr_ha2)
        ha2_gateway_ip            = data.google_compute_subnetwork.ha2.gateway_address
        external_lb_ip            = google_compute_address.external_nat_ip.address
        workload_vm               = cidrhost(var.cidr_trust, 5)
      }
  }
    
} */


