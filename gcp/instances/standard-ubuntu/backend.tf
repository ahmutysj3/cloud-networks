terraform {
  backend "gcs" {
    bucket = "trace_terraform_perm_bucket"
    prefix = "gcp/vms/instances/standard-ubuntu"
  }
}
