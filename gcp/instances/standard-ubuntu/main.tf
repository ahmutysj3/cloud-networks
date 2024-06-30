data "google_compute_image" "this" {
  for_each = { for k, v in var.instances : v.name => v }
  project  = each.value.image["project"]
  name     = each.value.image["name"]
}

output "image" {
  value = data.google_compute_image.this
}

output "subnet" {
  value = data.google_compute_subnetwork.this
}

data "google_compute_subnetwork" "this" {
  for_each = { for k, v in var.instances : v.name => v }
  project  = each.value.nic["vpc_project"]
  region   = var.gcp_region
  name     = each.value.nic["subnet"]
}

data "google_compute_zones" "available" {
  region = var.gcp_region
}

resource "google_compute_address" "external" {
  for_each     = { for k, v in var.instances : v.name => v if v.nic["assign_public_ip"] == true }
  name         = "${each.value.name}-external-ip"
  project      = each.value.nic["vpc_project"]
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}

resource "google_compute_address" "internal" {
  for_each     = { for k, v in var.instances : v.name => v }
  name         = "${each.value.name}-internal-ip"
  project      = each.value.nic["vpc_project"]
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.this[each.key].self_link
  address      = each.value.nic["address"]
}

variable "instances" {
  description = "The instances to create"
  type = list(object({
    name       = string
    vm_project = string
    image = object({
      name    = string
      project = string
    })
    tags         = list(string)
    machine_type = optional(string)
    zone         = optional(string)
    nic = object({
      subnet           = string
      vpc_project      = string
      assign_public_ip = bool
      address          = optional(string)
    })
  }))
  default = [{
    name         = "instance-1"
    vm_project   = "trace-vm-instances-01"
    machine_type = "e2-micro"
    zone         = "us-east4-a"
    image = {
      name    = "ubuntu-2004-focal-v20240209"
      project = "ubuntu-os-cloud"
    }
    nic = {
      assign_public_ip = true
      vpc_project      = "trace-vpc-app-prod-01"
      subnet           = "app-subnet-01"
      address          = null
    }
    tags = []
  }]
}
