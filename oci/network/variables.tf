variable "region_pri" {
  description = "oci shorthand for us east ashburn region"
  type        = string
}

variable "internet_gateway_enabled" {
  default = true
}

variable "main_compartment" {
  description = "ocid for tenancy compartment"
  type        = string
  sensitive   = true
}

variable "spoke_subnets" {
  description = "subnet params for spoke VCNs"
  type = map(object({
    cidr     = string
    private  = bool
    vcn      = string
    instance = string
  }))
}

variable "dc_name" {
  description = "used as prefix for multiple resource display names"
  type        = string
}

variable "hub_vcn_cidr" {
  description = "cidr block for hub vcn"
  type        = string
}

variable "supernet_cidr" {
  description = "datacenter supernet"
  type        = string
}

variable "spoke_vcns" {
  description = "create spoke VCNs"
  type = map(object({
    cidr = string
  }))
}


variable "shape" {
  description = "The shape of an instance."
  type        = string
  default     = "VM.Standard.A1.Flex"
}

/* variable "path_oci_local_public_key" { # LAPTOP
  default   = "~/.oci/trace-oci-key2.pub"
  sensitive = true
} */

variable "path_oci_local_public_key" { # PC
  default   = "~/.oci/oci_api_key_public.pem"
  sensitive = true
}

variable "operating_system" {
  description = "used for filtering data on OS images"
  type        = map(string)
  default = {
    os      = "Canonical Ubuntu"
    version = "22.04"
  }
}

variable "custom_image" {
  description = "used for pfsense image in bucket"
  type        = string
  default     = "pfsense.img"
}

variable "shape_config" {
  description = "used for configuring shape"
  type        = map(string)
  default = {
    memory_in_gbs             = 8
    ocpus                     = 3
    baseline_ocpu_utilization = "BASELINE_1_1"
  }
}

variable "agent_config" {
  description = "used for cloud agent configurations"
  type        = map(bool)
  default = {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false
  }
}

variable "deploy_fw" {
  description = "deploys linux instances preloaded with pfsense"
  type        = bool
}

variable "bucket" {
  description = "name of bucket containing pfsense img"
  default     = "bucket-20221114-1400"
}

variable "nsg_params" {
  type = map(object({
    rules = map(object({
      description = string
      source_type = string
      allow_from  = string
      ports = map(object({
        protocol = string
        min      = number
        max      = number
        type     = number
        code     = number
      }))
    }))
  }))
}