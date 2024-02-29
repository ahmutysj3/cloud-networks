data "google_compute_zones" "this" {
  region = var.config.region
}

data "google_compute_image" "this" {
  project = "paloaltonetworksgcp-public"
  family  = "panorama-10"
}

data "google_compute_default_service_account" "default" {
}

data "google_compute_network" "this" {
  name = "test-vpc"
}

data "google_compute_subnetwork" "this" {
  name = "test-subnet"
}

resource "google_compute_instance" "this" {
  name                      = "test-pano"
  zone                      = data.google_compute_zones.this.names[0]
  machine_type              = "n2-standard-8"
  project                   = var.config.project_id
  can_ip_forward            = false
  allow_stopping_for_update = true
  tags                      = ["allow-all"]

  metadata = {
    serial-port-enable = true
    ssh-keys           = "admin:${file("~/.ssh/id_rsa.pub")}"
  }


  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.this.self_link
    access_config {
      nat_ip = ""
    }
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.this.self_link
      size  = 224
    }
  }
}

resource "panos_address_object" "example" {
  name        = "localnet"
  value       = "192.168.80.0/24"
  description = "The 192.168.80 network"
  tags = [
    "internal",
    "dmz",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "panos_panorama_administrative_tag" "example" {
  for_each = { for k, v in ["internal", "dmz"] : k => v }
  name     = each.value
  color    = "color${each.key + 2}"
  comment  = "${each.value} resources"

  lifecycle {
    create_before_destroy = true
  }
}

resource "panos_panorama_device_group" "example" {
  name = "test"

  lifecycle {
    create_before_destroy = true
  }
}
resource "panos_panorama_template" "example" {
  name        = "template1"
  description = "description here"

  lifecycle {
    create_before_destroy = true
  }
}
