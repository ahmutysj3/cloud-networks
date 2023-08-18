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

variable "vault_client_cert" {}
variable "vault_client_key" {}
  
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