resource "google_compute_instance" "jumpbox2" {
  description  = "test-jumpbox2"
  hostname     = null
  labels       = {}
  machine_type = "e2-micro"
  metadata = {
    ssh-keys = "trace:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjI2kHRd2kAMmb8wbVmu66q/MfHhGiop6tZ1s7e9iJ+TzOK0S92cfIxrBTu08J6MhTg/CUfZwHe6WKB3sA5A2tWOLLpYdkvvwAojOh0z7hD9l8UZ57agRu0aaVfOofQwhQBWZFiOWIOUWmLAtHCxejV24ICJt/+pk1D+0MhqulKccC1Si7RZgzBqGzeH64mwgTbbl/QD3Hf2NcT5PvUZL9yWJDonoh1CZ5j4SfU/YJBBQXXsI3LJkH5gGCz2+CY+ZhZbtnCLrDMsgzK9uUSamdZ7bIiBi0LAM8P9O+QK75kBwnyRvQly92sIP50uxMGAfI8D/MfmHoP9pcTmHFbWcv trace@trace-laptop"
  }


  name    = "instance-2"
  project = "terraform-project-trace-lab"
  tags    = []
  zone    = "us-east1-b"
  boot_disk {
    auto_delete = true
    device_name = "ubuntu-boot-disk2"
    mode        = "READ_WRITE"
    source      = google_compute_disk.ubuntu_boot2.self_link
  }

  attached_disk {
    device_name = "ubuntu-data-disk2"
    mode        = "READ_WRITE"
    source      = google_compute_disk.ubuntu_data2.self_link
  }

  network_interface {
    network    = google_compute_network.protected.self_link
    network_ip = cidrhost(google_compute_subnetwork.protected.ip_cidr_range, 3)
    nic_type   = "GVNIC"
    stack_type = "IPV4_ONLY"
    subnetwork = google_compute_subnetwork.protected.self_link
  }

  scheduling {
    automatic_restart           = false
    instance_termination_action = "DELETE"
    on_host_maintenance         = "TERMINATE"
    preemptible                 = true
    provisioning_model          = "SPOT"
  }

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

}


resource "google_compute_disk" "ubuntu_boot2" {
  name                      = "ubuntu-boot-disk2"
  size                      = 10
  type                      = "pd-ssd"
  zone                      = data.google_compute_zones.available.names[0]
  image                     = data.google_compute_image.ubuntu.self_link
  physical_block_size_bytes = 4096
}

resource "google_compute_disk" "ubuntu_data2" {
  name                      = "ubuntu-data-disk2"
  size                      = 10
  type                      = "pd-ssd"
  zone                      = data.google_compute_zones.available.names[0]
  physical_block_size_bytes = 4096
}