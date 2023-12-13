variable "gcp_project" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "boot_disk_size" {
  description = "Size of the boot disk in GB"
  type        = number
}

variable "hc_port" {
  type = number
}

variable "web_subnets" {
  type = list(string)
}

variable "pfsense_name" {
  type = string
}

variable "pfsense_machine_image" {
  type = string
}

variable "deploy_fortigate" {
  type = bool
}

variable "deploy_pfsense" {
  type = bool
}

variable "default_fw_route" {
  type = bool
}

variable "ilb_next_hop" {
  type = bool
}
