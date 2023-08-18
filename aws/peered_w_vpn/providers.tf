provider "aws" {
  region  = var.aws_region
  #profile = "default"
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
}