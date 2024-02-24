variable "gcp_project" {
  type    = string
  default = "trace-terraform-perm"
}

variable "gcp_region" {
  type    = string
  default = "us-east1"
}

variable "boot_disk_size" {
  description = "Size of the boot disk in GB"
  type        = number
  default     = 10
}

variable "log_disk_size" {
  description = "Size of the log disk in GB"
  type        = number
  default     = 30
}
