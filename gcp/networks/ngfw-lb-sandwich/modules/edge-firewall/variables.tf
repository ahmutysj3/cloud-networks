variable "fw_network_interfaces" {
  type = list(object({
    vpc     = string
    subnet  = string
    ip_addr = string
  }))
}

variable "model" {
  type = string
}

variable "ssh_public_key" {
  type = string
}
