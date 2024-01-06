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

