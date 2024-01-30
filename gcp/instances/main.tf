resource "google_compute_instance" "this" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = data.google_compute_zones.available.names[0]

  tags = var.tags

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    stack_type = "IPV4_ONLY"
    subnetwork = data.google_compute_subnetwork.app.self_link
  }

  metadata_startup_script = file("startup.sh")

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

data "google_compute_default_service_account" "default" {
}

data "google_compute_networks" "all" {
  project = var.network_project
}

locals {
  app_network = [for networks in data.google_compute_networks.all.networks : networks if length(regexall("app", networks)) > 0]
}

data "google_compute_network" "app" {
  project = var.network_project
  name    = local.app_network[0]
}

data "google_compute_subnetwork" "app" {
  project = var.network_project
  region  = var.gcp_region
  name    = var.subnetwork_name
}

variable "subnetwork_name" {
  description = "The name of the subnetwork to use for the instance."
  type        = string
  default     = "app-vpc-application-subnet"

}

data "google_compute_zones" "available" {
  region = var.gcp_region
}
