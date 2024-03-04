resource "google_compute_address" "internal" {
  for_each     = var.fw_vnics
  name         = "${var.name}-${each.value.interface}-fw0${var.index}-ip"
  project      = var.project_id
  address_type = "INTERNAL"
  subnetwork   = var.fw_subnets[each.key].self_link
}

locals {
  output = { for k, v in var.fw_vnics : k => {
    ip        = google_compute_address.internal[k].address
    interface = v.interface
    subnet    = google_compute_address.internal[k].subnetwork
  } }
}

output "fw_ips" {
  value = local.output
}


variable "fw_vnics" {
  type = any
}

variable "project_id" {
  type = string
}

variable "index" {
  type = number
}

variable "name" {
  type = string
}

variable "fw_subnets" {
  type = any
}
