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
  alias   = "spoke"
  project = var.prod_vpc_project
  region  = var.gcp_region
}

provider "google-beta" {
  alias   = "spoke"
  project = var.prod_vpc_project
  region  = var.gcp_region
}
