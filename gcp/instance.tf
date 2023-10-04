/* resource "google_compute_instance" "fortigate-active" {
  name           = "fgt-active-fw"
  machine_type   = var.machine
  zone           = var.zone
  can_ip_forward = "true"

  tags = ["allow-fgt", "allow-internal"]

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