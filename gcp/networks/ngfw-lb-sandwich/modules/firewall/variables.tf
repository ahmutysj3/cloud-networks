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

variable "subnets" {
  type = map(object({
    name      = string
    cidr      = string
    self_link = string
    gateway   = string
  }))
}

variable "vpcs" {
  type = map(object({
    name      = string
    self_link = string
  }))
}

variable "default_service_account" {
  type = string
}

variable "zones" {
  type = list(string)
}

variable "image" {
  type = string
}

variable "hc_port" {
  type = number
}
