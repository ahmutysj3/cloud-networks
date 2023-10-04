/* resource "google_compute_instance" "fortigate-active" {
  name           = "fgt-active-fw"
  machine_type   = "e2-standard-4"
  zone           = data.google_compute_zones.available.names[0]
  can_ip_forward = "true"
  tags    = ["allow-fgt-mgmt", "allow-fgt-trusted", "allow-fgt-untrusted", "allow-fgt-ha"]
  project = var.gcp_project
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

    initialize_params {
      image = data.google_compute_image.fortigate.self_link
    }

    mode   = "READ_WRITE"
    source = google_compute_disk.boot.self_link
  }

  network_interface {
    access_config {
      nat_ip       = "35.229.111.55"
      network_tier = "PREMIUM"
    }

    network            = "https://www.googleapis.com/compute/v1/projects/terraform-project-trace-lab/global/networks/mgmt-network"
    network_ip         = "10.99.254.132"
    stack_type         = "IPV4_ONLY"
    subnetwork         = "https://www.googleapis.com/compute/v1/projects/terraform-project-trace-lab/regions/us-east1/subnetworks/admin-subnet"
    subnetwork_project = "terraform-project-trace-lab"
  }

  network_interface {
    access_config {
      nat_ip       = "35.196.230.250"
      network_tier = "PREMIUM"
    }

    network            = "https://www.googleapis.com/compute/v1/projects/terraform-project-trace-lab/global/networks/untrusted-network"
    network_ip         = "10.99.1.3"
    stack_type         = "IPV4_ONLY"
    subnetwork         = "https://www.googleapis.com/compute/v1/projects/terraform-project-trace-lab/regions/us-east1/subnetworks/fw-outside-subnet"
    subnetwork_project = "terraform-project-trace-lab"
  }

  network_interface {
    network            = "https://www.googleapis.com/compute/v1/projects/terraform-project-trace-lab/global/networks/fw-ha-network"
    network_ip         = "10.99.255.4"
    stack_type         = "IPV4_ONLY"
    subnetwork         = "https://www.googleapis.com/compute/v1/projects/terraform-project-trace-lab/regions/us-east1/subnetworks/fw-ha-subnet"
    subnetwork_project = "terraform-project-trace-lab"
  }

  network_interface {
    network            = "https://www.googleapis.com/compute/v1/projects/terraform-project-trace-lab/global/networks/trusted-network"
    network_ip         = "10.99.0.3"
    stack_type         = "IPV4_ONLY"
    subnetwork         = "https://www.googleapis.com/compute/v1/projects/terraform-project-trace-lab/regions/us-east1/subnetworks/fw-inside-subnet"
    subnetwork_project = "terraform-project-trace-lab"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "215092868248-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud.useraccounts.readonly", "https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_vtpm                 = true
  }

} */

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
  family  = "fortigate-74-payg"
  project = "fortigcp-project-001"
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

resource "google_compute_address" "fw_inside" {
  name         = "fw-inside-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.fw_trusted.self_link
  address      = cidrhost(google_compute_subnetwork.fw_trusted.ip_cidr_range, 2)
}

resource "google_compute_address" "fw_outside" {
  name         = "fw-outside-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.fw_untrusted.self_link
  address      = cidrhost(google_compute_subnetwork.fw_untrusted.ip_cidr_range, 2)
}

resource "google_compute_address" "fw_wan_external" {
  name = "fw-wan-external-ip"
  address_type = "EXTERNAL"
  ip_version = "IPV4"
  region = var.gcp_region
}

resource "google_compute_address" "fw_mgmt_external" {
  name = "fw-mgmt-external-ip"
  address_type = "EXTERNAL"
  ip_version = "IPV4"
  region = var.gcp_region
}
