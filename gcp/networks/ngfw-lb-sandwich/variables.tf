variable "gcp_project" {
  type    = string
  default = "terraform-project-trace-lab"
}

variable "gcp_region" {
  type    = string
  default = "us-east1"
}

variable "boot_disk_size" {
  description = "Size of the boot disk in GB"
  type        = number
  default     = 100
}

variable "hc_port" {
  type    = number
  default = 8008
}

variable "web_subnets" {
  type    = list(string)
  default = ["tracecloud", "birdperson", "squanchy"]
}

variable "pfsense_name" {
  type    = string
  default = "pfsense-active-fw"
}

variable "wan_nic_ip" {
  type = string
}

variable "lan_nic_ip" {
  type = string
}

variable "pfsense_machine_image" {
  type    = string
  default = "projects/terraform-project-trace-lab/global/machineImages/pfsense-full-configure-machine-image"
}
