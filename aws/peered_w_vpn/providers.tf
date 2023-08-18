provider "aws" {
  region  = var.aws_region
  profile = "default"
}

provider "vault" {
  #address = "https://vault.tracecloud.us:8200"
  auth_login_cert {
    cert_file = "/home/trace/vault-client-certs/terraform_client_cert.crt"
    key_file = "/home/trace/vault-client-certs/terraform_client_cert.pem"
    mount = "cert"
  }
}

resource "vault_kv_secret_v2" "test" {
  mount                      = "terraform"
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