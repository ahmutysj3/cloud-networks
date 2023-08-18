provider "aws" {
  region  = var.aws_region
  profile = "default"
}

provider "vault" {
  auth_login_cert {
    cert_file = var.vault_client_cert
    key_file = var.vault_client_key
    mount = "cert"
  }
}

# set ENV variables for vault
variable "vault_client_cert" {}
variable "vault_client_key" {}
  
data "vault_kv_secret" "test" {
  path = "terraform/test"
}

output "test" {
  value = data.vault_kv_secret.test
  sensitive = true

}