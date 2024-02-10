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
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }
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

resource "google_compute_firewall" "this" {
  count              = var.allow_all ? 1 : 0
  name               = "allow-all-rule"
  network            = data.google_compute_network.app.self_link
  project            = var.network_project
  direction          = "INGRESS"
  priority           = 1000
  source_ranges      = ["35.191.0.0/16", "130.211.0.0/22"]
  destination_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  target_tags = ["allow-all"]
}
