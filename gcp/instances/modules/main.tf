resource "google_compute_instance" "this" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = data.google_compute_zones.available.names[0]
  project      = var.vm_project
  tags         = var.tags

  boot_disk {
    initialize_params {
      image = data.google_compute_image.this.id
    }
  }

  network_interface {
    stack_type = "IPV4_ONLY"
    subnetwork = data.google_compute_subnetwork.app.self_link

    access_config {
      nat_ip = google_compute_address.this.address
    }
  }

  metadata_startup_script = var.startup_script

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_address" "this" {
  name         = "instance-nat-ip"
  project      = var.network_project
  address_type = "EXTERNAL"
}

data "google_compute_image" "this" {
  project = "ubuntu-os-cloud"
  name    = "ubuntu-2004-focal-v20240209"
}

data "google_compute_default_service_account" "default" {
}

data "google_compute_network" "app" {
  project = var.network_project
  name    = var.vpc_name
}

data "google_compute_subnetwork" "app" {
  project = var.network_project
  region  = var.gcp_region
  name    = var.subnetwork_name
}

data "google_compute_zones" "available" {
  region = var.gcp_region
}


