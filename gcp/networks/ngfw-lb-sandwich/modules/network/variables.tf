variable "gcp_project" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "web_subnets" {
  type = list(string)
}

variable "default_fw_route" {
  type = bool
}

variable "deploy_pfsense" {
  type = bool
}

variable "pfsense_machine_image" {
  type = string
}

variable "pfsense_name" {
  type = string
}

variable "ilb_next_hop" {
  type = bool
}

variable "hc_port" {
  type = number
}
