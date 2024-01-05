provider "google" {
  alias   = "edge"
  project = var.edge_project
  region  = var.gcp_region
}

provider "google-beta" {
  alias   = "edge"
  project = var.edge_project
  region  = var.gcp_region
}

provider "google" {
  alias   = "prod"
  project = var.prod_project
  region  = var.gcp_region
}

provider "google-beta" {
  alias   = "prod"
  project = var.prod_project
  region  = var.gcp_region
}

provider "google" {
  alias   = "bu1"
  project = var.bu1_project
  region  = var.gcp_region
}

provider "google-beta" {
  alias   = "bu1"
  project = var.bu1_project
  region  = var.gcp_region
}

provider "google" {
  alias   = "bu2"
  project = var.bu2_project
  region  = var.gcp_region
}

provider "google-beta" {
  alias   = "bu2"
  project = var.bu2_project
  region  = var.gcp_region
}

provider "google" {
  alias   = "dev"
  project = var.dev_project
  region  = var.gcp_region
}

provider "google-beta" {
  alias   = "dev"
  project = var.dev_project
  region  = var.gcp_region
}

