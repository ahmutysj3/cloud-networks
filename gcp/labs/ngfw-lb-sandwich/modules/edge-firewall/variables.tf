variable "fw_network_interfaces" {
  type = list(object({
    vpc     = string
    subnet  = string
    ip_addr = string
    gateway = string
  }))
}

variable "model" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "lb_types" {
  type    = list(string)
  default = ["ilb", "elb"]
}

variable "gui_port" {
  type = number
}

variable "fw_public_interface" {
  type = string
}

variable "address_params" {
  description = "ip address params"
  type        = map(string)
  default = {
    ip_version   = "IPV4"
    address_type = "EXTERNAL"
  }
}
