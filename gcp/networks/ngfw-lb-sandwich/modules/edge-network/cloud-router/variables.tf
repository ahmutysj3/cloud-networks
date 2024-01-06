variable "vpc_name" {
  type = string
}

variable "network" {
  type = string
}

variable "nat_ip_allocate_option" {
  type    = string
  default = "AUTO_ONLY"
}

variable "source_subnetwork_ip_ranges_to_nat" {
  type    = string
  default = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

variable "log_config" {
  type = map(string)
  default = {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
