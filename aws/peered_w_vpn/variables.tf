variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

# set ENV variables for vault
variable "vault_client_cert" {}
variable "vault_client_key" {}