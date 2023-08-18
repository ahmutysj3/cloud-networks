terraform {

  backend "local" {
    path = "./terraform.tfstate"
  }

  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "3.19.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "5.13.0"
    }
  }

}