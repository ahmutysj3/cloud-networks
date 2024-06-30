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
    machine_type = string
    zone         = string
    nic = object({
      subnet           = string
      vpc_project      = string
      assign_public_ip = bool
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
    }
    tags = []
  }]
}
