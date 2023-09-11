provider "aws" {
  region     = var.aws_region
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
}

provider "vault" {
  auth_login_cert {
    cert_file = var.vault_client_cert
    key_file = var.vault_client_key
  }
}