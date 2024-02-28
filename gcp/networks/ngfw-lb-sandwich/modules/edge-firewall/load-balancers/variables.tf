variable "hc_port" {
  type = number
}

variable "instance_groups" {
  type = map(string)
}

variable "lb_type" {
  type = string
}

variable "trusted_subnet" {
  type = string
}


variable "trusted_network" {
  type = string
}
