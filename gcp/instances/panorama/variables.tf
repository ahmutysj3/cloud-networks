# General
variable "project" {
  description = "The project name to deploy the infrastructure in to."
  type        = string
  default     = null
}

variable "region" {
  description = "The region into which to deploy the infrastructure in to"
  type        = string
  default     = ""
}

variable "name_prefix" {
  description = "A string to prefix resource namings"
  type        = string
  default     = ""
}

# Panorama
variable "panoramas" {
  description = <<-EOF
    A map containing each panorama setting.

    Example of variable deployment :

    ```
    panoramas = {
      "panorama-01" = {
        panorama_name     = "panorama-01"
        panorama_vpc      = "panorama-vpc"
        panorama_subnet   = "panorama-subnet"
        panorama_version  = "panorama-byol-1000"
        ssh_keys          = "admin:PUBLIC-KEY"
        attach_public_ip  = true
        private_static_ip = "172.21.21.2"
      }
    }
    ```
  
    For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-swfw-modules/tree/main/modules/panorama#inputs)

    Multiple keys can be added and will be deployed by the code
    EOF
}