
variable "project_id" {
  type = string

}

variable "ssh_key" {
  description = "ssh pubkey to be used in bootstrap process"
  type        = string
  default     = ""
}

variable "name" {
  type = string
}

variable "fw_vnics" {
  type = any
}

variable "index" {
  type = number
}

variable "machine_type" {
  type = string
}

variable "disk_params" {
  type = map(string)
}

variable "region" {
  type = string

}

variable "fw_subnets" {
  type = any
}

variable "image" {
  type = string
}

variable "addresses" {
  type = any
}

variable "bootstrap_bucket" {
  type = string

}
