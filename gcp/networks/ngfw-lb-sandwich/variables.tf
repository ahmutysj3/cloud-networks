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

