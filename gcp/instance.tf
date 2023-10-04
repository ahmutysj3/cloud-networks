resource "google_compute_instance" "fortigate-active" {
  name           = "fgt-active-fw"
  machine_type   = "e2-standard-4"
  zone           = data.google_compute_zones.available.names[0]
  can_ip_forward = "true"
  tags           = ["allow-fgt-mgmt", "allow-fgt-trusted", "allow-fgt-untrusted", "allow-fgt-ha"]
  project        = var.gcp_project
  metadata = {
    fortigate_user_password  = "yhhR.8u7"
    google-logging-enable    = "0"
    ATTACHED_DISKS           = "log-disk"
    google-monitoring-enable = "0"
  }


  attached_disk {
    device_name = "log-disk"
    mode        = "READ_WRITE"
    source      = google_compute_disk.log.self_link
  }

  boot_disk {
    auto_delete = true
    device_name = "boot-disk"
    mode   = "READ_WRITE"
    source = google_compute_disk.boot.self_link
  }

  network_interface { # GUI/MGMT Interface
    access_config {
      nat_ip       = google_compute_address.fw_mgmt_external.address
      network_tier = "PREMIUM"
    }

    network            = google_compute_network.mgmt.self_link
    network_ip         = google_compute_address.fw_mgmt.address
    stack_type         = "IPV4_ONLY"
    subnetwork         = google_compute_subnetwork.fw_mgmt.self_link
    subnetwork_project = var.gcp_project
  }

  network_interface { # WAN Interface
    access_config {
      nat_ip       = google_compute_address.fw_wan_external.address
      network_tier = "PREMIUM"
    }

    network            = google_compute_network.untrusted.self_link
    network_ip         = google_compute_address.fw_wan.address
    stack_type         = "IPV4_ONLY"
    subnetwork         = google_compute_subnetwork.fw_untrusted.self_link
    subnetwork_project = var.gcp_project
  }

  network_interface { # HA SYNC Interface
    network            = google_compute_network.ha_sync.self_link
    network_ip         = google_compute_address.fw_ha_sync.address
    stack_type         = "IPV4_ONLY"
    subnetwork         = google_compute_subnetwork.fw_ha_sync.self_link
    subnetwork_project = var.gcp_project
  }

  network_interface { # LAN Interface
    network            = google_compute_network.trusted.self_link
    network_ip         = google_compute_address.fw_lan.address
    stack_type         = "IPV4_ONLY"
    subnetwork         = google_compute_subnetwork.fw_trusted.self_link
    subnetwork_project = var.gcp_project
  }

  /* scheduling { # Normal Rates
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    provisioning_model  = "STANDARD"
  } */

  scheduling { # Discounted Rates
    automatic_restart  = false
    preemptible        = true
    provisioning_model = "SPOT"
  }

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_vtpm                 = true
  }

}

resource "google_compute_disk" "boot" {
  image                     = data.google_compute_image.fortigate.self_link
  name                      = "fortigate-boot-disk"
  physical_block_size_bytes = 4096
  project                   = var.gcp_project
  size                      = var.boot_disk_size
  type                      = "pd-ssd"
  zone                      = data.google_compute_zones.available.names[0]
}

resource "google_compute_disk" "log" {
  name                      = "fortigate-log-disk"
  physical_block_size_bytes = 4096
  project                   = var.gcp_project
  size                      = var.log_disk_size
  type                      = "pd-ssd"
  zone                      = data.google_compute_zones.available.names[0]
}

data "google_compute_image" "fortigate" {
  provider = google
  family   = "fortigate-74-payg"
  project  = "fortigcp-project-001"
}

data "google_compute_zones" "available" {
  region = var.gcp_region
}

data "google_compute_default_service_account" "default" {
}

resource "google_compute_address" "fw_ha_sync" {
  name         = "fw-ha-sync-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.fw_ha_sync.self_link
  address      = cidrhost(google_compute_subnetwork.fw_ha_sync.ip_cidr_range, 2)
}

resource "google_compute_address" "fw_mgmt" {
  name         = "fw-mgmt-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.fw_mgmt.self_link
  address      = cidrhost(google_compute_subnetwork.fw_mgmt.ip_cidr_range, 2)
}

resource "google_compute_address" "fw_lan" {
  name         = "fw-inside-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.fw_trusted.self_link
  address      = cidrhost(google_compute_subnetwork.fw_trusted.ip_cidr_range, 2)
}

resource "google_compute_address" "fw_wan" {
  name         = "fw-outside-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.fw_untrusted.self_link
  address      = cidrhost(google_compute_subnetwork.fw_untrusted.ip_cidr_range, 2)
}

resource "google_compute_address" "fw_wan_external" {
  name         = "fw-wan-external-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  region       = var.gcp_region
}

resource "google_compute_address" "fw_mgmt_external" {
  name         = "fw-mgmt-external-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  region       = var.gcp_region
}
