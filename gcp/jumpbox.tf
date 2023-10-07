resource "google_compute_instance" "jumpbox" {
  description               = "test-jumpbox"
  hostname                  = null
  labels                    = {}
  machine_type              = "e2-micro"
  metadata = {
    ssh-keys = "trace:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjI2kHRd2kAMmb8wbVmu66q/MfHhGiop6tZ1s7e9iJ+TzOK0S92cfIxrBTu08J6MhTg/CUfZwHe6WKB3sA5A2tWOLLpYdkvvwAojOh0z7hD9l8UZ57agRu0aaVfOofQwhQBWZFiOWIOUWmLAtHCxejV24ICJt/+pk1D+0MhqulKccC1Si7RZgzBqGzeH64mwgTbbl/QD3Hf2NcT5PvUZL9yWJDonoh1CZ5j4SfU/YJBBQXXsI3LJkH5gGCz2+CY+ZhZbtnCLrDMsgzK9uUSamdZ7bIiBi0LAM8P9O+QK75kBwnyRvQly92sIP50uxMGAfI8D/MfmHoP9pcTmHFbWcv trace@trace-laptop"
  }


  name                    = "instance-1"
  project                 = "terraform-project-trace-lab"
  tags                    = []
  zone                    = "us-east1-b"
  boot_disk {
    auto_delete             = true
    device_name             = "ubuntu-boot-disk"
    mode                    = "READ_WRITE"
    source                  = google_compute_disk.ubuntu_boot.self_link
  }
  
  attached_disk {
    device_name             = "ubuntu-data-disk"
    mode                    = "READ_WRITE"
    source                  = google_compute_disk.ubuntu_data.self_link
  }

  network_interface {
    network                     = "https://www.googleapis.com/compute/v1/projects/terraform-project-trace-lab/global/networks/default"
    network_ip                  = "10.142.0.4"
    nic_type                    = "GVNIC"
    stack_type                  = "IPV4_ONLY"
    subnetwork                  = "https://www.googleapis.com/compute/v1/projects/terraform-project-trace-lab/regions/us-east1/subnetworks/default"
    
    access_config {
      nat_ip                 = "34.139.230.152"
      network_tier           = "PREMIUM"
      public_ptr_domain_name = null
    }
  }

  scheduling {
    automatic_restart           = false
    instance_termination_action = "DELETE"
    on_host_maintenance         = "TERMINATE"
    preemptible                 = true
    provisioning_model          = "SPOT"
  }
  service_account {
    email  = "215092868248-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }
  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

}


 data "google_compute_image" "ubuntu" {
   family = "ubuntu-2204-lts"
   project = "ubuntu-os-cloud"
 }

 resource "google_compute_disk" "ubuntu_boot" {
  name  = "ubuntu-boot-disk"
  size = 10
  type  = "pd-ssd"
  zone  = data.google_compute_zones.available.names[0]
  image = data.google_compute_image.ubuntu.self_link
  physical_block_size_bytes = 4096
}

resource "google_compute_disk" "ubuntu_data" {
  name  = "ubuntu-data-disk"
  size = 10
  type  = "pd-ssd"
  zone  = data.google_compute_zones.available.names[0]
  physical_block_size_bytes = 4096
}