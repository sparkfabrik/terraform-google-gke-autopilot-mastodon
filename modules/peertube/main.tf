locals {
  peertube_default_labels = { "app" = "peertube", "project" = var.name }
  s3_k8s_secret_name      = format("%s-%s", replace(var.name, "_", "-"), "s3-secret")
  sql_k8s_secret_name     = format("%s-%s", replace(var.name, "_", "-"), "postgres-pwd")
}

# https://docs.joinpeertube.org/maintain/remote-storage
resource "google_storage_bucket" "peertube_buckets" {
  for_each                    = { for s in var.peertube_buckets : s.name => s }
  name                        = "${var.name}-${each.key}"
  project                     = var.project_id
  location                    = each.value.location != null ? each.value.location : var.bucket_location
  storage_class               = each.value.storage_class
  uniform_bucket_level_access = false
  labels                      = local.peertube_default_labels
  force_destroy               = var.bucket_force_destroy
  versioning {
    enabled = var.bucket_versioning
  }
  logging {
    log_bucket = google_storage_bucket.peertube_buckets_logs[each.key].name
  }
  # https://docs.joinpeertube.org/maintain/remote-storage#cors-settings
  # https://vamsiramakrishnan.medium.com/a-study-on-using-google-cloud-storage-with-the-s3-compatibility-api-324d31b8dfeb
  cors {
    origin          = ["*"]
    method          = ["GET"]
    response_header = ["*"]
  }
}

resource "google_storage_bucket" "peertube_buckets_logs" {
  for_each                    = { for s in var.peertube_buckets : s.name => s }
  name                        = "peertube-${each.key}-logs-${var.name}"
  project                     = var.project_id
  location                    = each.value.location != null ? each.value.location : var.bucket_location
  storage_class               = each.value.storage_class
  uniform_bucket_level_access = false
  labels                      = local.peertube_default_labels
  versioning {
    enabled = var.bucket_versioning
  }
}

resource "google_service_account" "peertube_service_account" {
  project      = var.project_id
  account_id   = "${var.name}-sa"
  display_name = "Service account for ${var.name} peertube buckets"
}

resource "google_storage_bucket_iam_member" "peertube_bucket_members" {
  for_each = { for s in var.peertube_buckets : s.name => s }
  bucket   = google_storage_bucket.peertube_buckets[each.key].name
  role     = "roles/storage.admin"
  member   = "serviceAccount:${google_service_account.peertube_service_account.email}"
}

resource "google_storage_hmac_key" "peertube_bucket_sa_hmac_key" {
  service_account_email = google_service_account.peertube_service_account.email
  project               = var.project_id
}

resource "kubernetes_namespace" "peertube" {
  provider = kubernetes
  metadata {
    name = var.kubernetes_namespace
  }
}

resource "kubernetes_secret" "bucket_secret" {
  metadata {
    name      = local.s3_k8s_secret_name
    namespace = kubernetes_namespace.peertube.id
  }
  data = {
    AWS_ACCESS_KEY_ID     = google_storage_hmac_key.peertube_bucket_sa_hmac_key.access_id
    AWS_SECRET_ACCESS_KEY = google_storage_hmac_key.peertube_bucket_sa_hmac_key.secret
  }
  depends_on = [kubernetes_namespace.peertube]
}

### Postgresql database.
resource "google_sql_user" "peertube_sql_user" {
  name     = "peertube"
  instance = var.cloudsql_instance_name
  password = module.peertube_db_pass.secret_value
}

resource "google_sql_database" "mastodon_sql_database" {
  name     = "peertube"
  project  = var.project_id
  instance = var.cloudsql_instance_name
}

module "peertube_db_pass" {
  source          = "sparkfabrik/gke-gitlab/sparkfabrik//modules/secret_manager"
  version         = "2.17.1"
  project         = var.project_id
  region          = var.region
  secret_id       = ""
  k8s_namespace   = kubernetes_namespace.peertube.id
  k8s_secret_name = local.sql_k8s_secret_name
  k8s_secret_key  = "password"
  depends_on      = [kubernetes_namespace.peertube]
}
