provider "aws" {
  region  = var.aws_region
  profile = "default"
}

provider "vault" {
  address = "https://vault.tracecloud.us:8200"
  auth_login_cert {
    cert_file = "/home/trace/vault-client-certs/terraform_server.crt"
    key_file = "/home/trace/vault-client-certs/terraform_server.pem"
    mount = "cert"
  }
}

data "vault_auth_backends" "example" {}