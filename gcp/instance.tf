/* resource "google_compute_instance" "fortigate-active" {
  name           = "fgt-active-fw"
  machine_type   = "e2-standard-4"
  zone           = "us-east1-b"
  can_ip_forward = "true"

  tags = ["allow-fgt"]

  boot_disk {
    initialize_params {
      image = var.nictype == "GVNIC" ? google_compute_image.fgtvmgvnic[0].self_link : var.image
    }
  }
  attached_disk {
    source = google_compute_disk.logdisk.name
  }
  network_interface {
    subnetwork = google_compute_subnetwork.public_subnet.name
    nic_type   = var.nictype
    access_config {
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.name
    nic_type   = var.nictype
  }
  metadata = {
    user-data = fileexists("${path.module}/${var.user_data}") ? "${file(var.user_data)}" : null
    license   = fileexists("${path.module}/${var.license_file}") ? "${file(var.license_file)}" : null
  }
  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  scheduling {
    preemptible       = false
    automatic_restart = false
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
  family  = "fortigate-74-payg"
  project = "fortigcp-project-001"
}

data "google_compute_zones" "available" {
}