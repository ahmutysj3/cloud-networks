variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "fw_networks" {
  type = map(string)
}

variable "prefix" {
  type = string
}
