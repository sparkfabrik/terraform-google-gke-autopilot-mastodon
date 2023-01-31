resource "google_storage_bucket" "bucket" {
  name                        = var.name
  project                     = var.project_id
  location                    = var.bucket_location
  storage_class               = var.bucket_storage_class
  uniform_bucket_level_access = true
  labels                      = local.gcp_default_labels
  force_destroy               = var.bucket_force_destroy
  versioning {
    enabled = var.bucket_versioning
  }
  logging {
    log_bucket = google_storage_bucket.log_bucket.name
  }
}

resource "google_storage_bucket" "log_bucket" {
  name                        = "${var.name}-logs"
  project                     = var.project_id
  location                    = var.bucket_location
  storage_class               = var.bucket_storage_class
  uniform_bucket_level_access = true
  labels                      = local.gcp_default_labels
}

resource "google_storage_bucket_iam_member" "bucket_members" {
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_service_account" "service_account" {
  project      = var.project_id
  account_id   = "${var.name}-sa"
  display_name = "Service account for ${var.name} application bucket"
}

resource "google_storage_hmac_key" "bucket_sa_hmac_key" {
  service_account_email = google_service_account.service_account.email
  project               = var.project_id
}

resource "kubernetes_secret" "s3_secret" {
  metadata {
    name      = local.s3_k8s_secret_name
    namespace = kubernetes_namespace.mastodon.id
  }
  data = {
    AWS_ACCESS_KEY_ID     = google_storage_hmac_key.bucket_sa_hmac_key.access_id
    AWS_SECRET_ACCESS_KEY = google_storage_hmac_key.bucket_sa_hmac_key.secret
  }
  depends_on = [kubernetes_namespace.mastodon]
}
