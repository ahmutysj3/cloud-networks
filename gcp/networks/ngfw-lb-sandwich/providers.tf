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
  alias   = "spoke1"
  project = var.prod_vpc_project
  region  = var.gcp_region
}

provider "google-beta" {
  alias   = "spoke1"
  project = var.prod_vpc_project
  region  = var.gcp_region
}

provider "google" {
  alias   = "spoke2"
  project = var.dev_vpc_project
  region  = var.gcp_region
}

provider "google-beta" {
  alias   = "spoke2"
  project = var.dev_vpc_project
  region  = var.gcp_region
}

