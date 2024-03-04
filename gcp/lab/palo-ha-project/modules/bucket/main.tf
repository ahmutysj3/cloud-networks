resource "google_storage_bucket" "this" {
  name                        = "${var.prefix}-bootstrap-bucket"
  force_destroy               = true
  uniform_bucket_level_access = true
  location                    = "us"

  versioning {
    enabled = true
  }
}

output "bucket_name" {
  value = google_storage_bucket.this.name
}

resource "google_storage_bucket_object" "config_empty" {
  name    = "config/"
  content = "config/"
  bucket  = google_storage_bucket.this.name
}

resource "google_storage_bucket_object" "content_empty" {
  name    = "content/"
  content = "content/"
  bucket  = google_storage_bucket.this.name
}

resource "google_storage_bucket_object" "license_empty" {
  name    = "license/"
  content = "license/"
  bucket  = google_storage_bucket.this.name
}

resource "google_storage_bucket_object" "software_empty" {
  name    = "software/"
  content = "software/"
  bucket  = google_storage_bucket.this.name
}

data "google_compute_default_service_account" "this" {}

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.this.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${data.google_compute_default_service_account.this.email}"
}

resource "google_storage_bucket_object" "file" {
  name   = "config/init-cfg.txt"
  source = "${path.module}/bootstrap_files/init-cfg.txt"
  bucket = google_storage_bucket.this.name
}

variable "prefix" {
  description = "The prefix to use for the bucket name"
  type        = string
  default     = "trace-test-"
}
