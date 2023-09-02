provider "vault" {
  auth_login_cert {
    cert_file = var.vault_client_cert
    key_file = var.vault_client_key
  }
}

# set ENV variables for vault
variable "vault_client_cert" {}
variable "vault_client_key" {}
  
data "vault_aws_access_credentials" "creds" {
  backend = "aws"
  role    = "terraform-user"
}

