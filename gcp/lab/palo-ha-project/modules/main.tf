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

data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
}


data "google_compute_subnetwork" "this" {
  for_each = local.fw_vnics
  project  = each.value.subnet_project
  region   = var.region
  name     = each.value.subnet
}

module "addresses" {
  source     = "./addresses"
  count      = 2
  name       = var.name
  project_id = var.project_id
  index      = count.index
  fw_subnets = data.google_compute_subnetwork.this
  fw_vnics   = local.fw_vnics
}

locals {
  bootstrap_ips = {
    vm01 = {
      zone                 = data.google_compute_zones.available.names[0]
      untrusted_private_ip = module.addresses[0].fw_ips[0].ip
      mgmt_private_ip      = module.addresses[0].fw_ips[1].ip
      mgmt_peer_private_ip = module.addresses[1].fw_ips[1].ip
      ha_private_ip        = module.addresses[0].fw_ips[2].ip
      trusted_private_ip   = module.addresses[0].fw_ips[3].ip
      untrusted_gateway_ip = data.google_compute_subnetwork.this[0].gateway_address
      mgmt_gateway_ip      = data.google_compute_subnetwork.this[1].gateway_address
      ha_gateway_ip        = data.google_compute_subnetwork.this[2].gateway_address
      trusted_gateway_ip   = data.google_compute_subnetwork.this[3].gateway_address
    }
    vm02 = {
      zone                 = data.google_compute_zones.available.names[1]
      untrusted_private_ip = module.addresses[1].fw_ips[0].ip
      mgmt_private_ip      = module.addresses[1].fw_ips[1].ip
      mgmt_peer_private_ip = module.addresses[0].fw_ips[1].ip
      ha_private_ip        = module.addresses[1].fw_ips[2].ip
      trusted_private_ip   = module.addresses[1].fw_ips[3].ip
      untrusted_gateway_ip = data.google_compute_subnetwork.this[0].gateway_address
      mgmt_gateway_ip      = data.google_compute_subnetwork.this[1].gateway_address
      ha_gateway_ip        = data.google_compute_subnetwork.this[2].gateway_address
      trusted_gateway_ip   = data.google_compute_subnetwork.this[3].gateway_address
    }
  }
}

output "fw_ips" {
  value = local.bootstrap_ips
}

module "fw_instances" {
  source           = "./vms"
  count            = 2
  addresses        = module.addresses[count.index].fw_ips
  fw_vnics         = local.fw_vnics
  fw_subnets       = data.google_compute_subnetwork.this
  project_id       = var.project_id
  region           = var.region
  ssh_key          = var.ssh_key
  name             = var.name
  index            = count.index
  image            = var.compute_params.image_name
  machine_type     = var.compute_params.machine_type
  disk_params      = var.disk_params
  bootstrap_bucket = module.bootstrap_bucket.bucket_name
}

module "bootstrap_bucket" {
  source = "./bucket"
  prefix = "${var.name}-"

}


