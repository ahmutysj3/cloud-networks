provider "aws" {
  region  = var.aws_region
  profile = "default"
}

provider "vault" {
  address = "https://vault.tracecloud.us:8200"
  auth_login_cert {
    cert_file = "/home/trace/vault-client-certs/terraform_client_cert.crt"
    key_file = "/home/trace/vault-client-certs/terraform_client_cert.pem"
    mount = "cert"
  }
}

data "vault_auth_backends" "example" {}

resource "vault_mount" "kvv2" {
  path        = "test-kv"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "example" {
  mount                      = "test-kv"
  name                       = "secret"
  cas                        = 1
  delete_all_versions        = true
  data_json                  = jsonencode(
  {
    zip       = "zap",
    foo       = "bar"
  }
  )
  custom_metadata {
    max_versions = 5
    data = {
      foo = "vault@example.com",
      bar = "12345"
    }
  }
}