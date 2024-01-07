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

variable "fw_gui_port" {
  type    = number
  default = 8001
}
