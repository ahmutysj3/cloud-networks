provider "google" {
  project = var.vm_project
  region  = var.gcp_region
}

provider "google-beta" {
  project = var.vm_project
  region  = var.gcp_region

}

provider "cloudflare" {
}
