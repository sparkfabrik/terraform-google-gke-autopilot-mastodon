locals {
  mastodon_release_helm_values = templatefile(
    "${path.module}/helm/values.yaml",
    {
      MASTODON_CREATE_ADMIN : var.app_create_admin
      MASTODON_ADMIN_USERNAME : var.app_admin_username
      MASTODON_ADMIN_EMAIL : var.app_admin_email
      MASTODON_LOCALE : var.app_locale
      MASTODON_LOCAL_DOMAIN : var.domain
      MASTODON_S3_EXISTING_SECRET : var.app_s3_existing_secret != null ? var.app_s3_existing_secret : kubernetes_secret.s3_secret.metadata[0].name
      MASTODON_S3_BUCKET_NAME : google_storage_bucket.bucket.name
      MASTODON_SMTP_EXISTING_SECRET : var.app_smtp_existing_secret != null ? var.app_smtp_existing_secret : (var.smtp_gcp_existing_secret_name != null ? local.smtp_k8s_secret_name_from_gcp : null)
      MASTODON_APP_EXISTING_SECRET_NAME : var.app_existing_secret_name != null ? var.app_existing_secret_name : kubernetes_secret.mastodon_secrets.metadata[0].name
      MASTODON_POSTGRES_HOST : module.sql_db.private_ip_address
      MASTODON_POSTGRES_USER : "mastodon"
      MASTODON_POSTGRES_DB : "mastodon"
      MASTODON_POSTGRES_SECRET_NAME : local.sql_k8s_secret_name
      MASTODON_GLOBAL_IP_NAME : local.mastodon_gcp_app_lb_ip_name
      MASTODON_REDIS_SECRET_NAME : kubernetes_secret.mastodon_redis_secret.metadata[0].name
      NAME : var.name
    }
  )
  mastodon_gcp_managed_cert_manifest = templatefile(
    "${path.module}/manifests/gcp-managed-cert.yaml",
    {
      MASTODON_LOCAL_DOMAIN : var.domain
      NAME : var.name
    }
  )
}


locals {
  mastodon_secrets = {
    for key, value in google_secret_manager_secret.mastodon_secrets :
    upper(key) => value.secret_id
  }
}

# Mastodon secrets.
resource "random_password" "mastodon_secrets_random" {
  for_each = var.app_keys
  length   = 32
  special  = false
}

resource "google_secret_manager_secret" "mastodon_secrets" {
  for_each  = var.app_keys
  project   = var.project_id
  secret_id = format("%s-%s", var.project_id, each.key)

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "mastodon_secrets_values" {
  for_each    = var.app_keys
  secret      = google_secret_manager_secret.mastodon_secrets[each.key].id
  secret_data = random_password.mastodon_secrets_random[each.key].result
}

resource "kubernetes_secret" "mastodon_secrets" {
  metadata {
    name      = local.mastodon_k8s_secret_name
    namespace = kubernetes_namespace.mastodon.id
  }
  data       = local.mastodon_secrets
  depends_on = [kubernetes_namespace.mastodon]
}

# Redis secret.
resource "random_password" "mastodon_redis_secret_random" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "mastodon_redis_secret" {
  metadata {
    name      = local.redis_k8s_secret_name
    namespace = kubernetes_namespace.mastodon.id
  }
  data       = { redis-password = random_password.mastodon_redis_secret_random.result }
  depends_on = [kubernetes_namespace.mastodon]
}

# SMTP existing secret.
module "mastodon_smtp_pass_from_gcp_existing_secret" {
  count           = var.smtp_gcp_existing_secret_name != null ? 1 : 0
  source          = "sparkfabrik/gke-gitlab/sparkfabrik//modules/secret_manager"
  version         = "2.14.0"
  project         = var.project_id
  region          = var.region
  secret_id       = var.smtp_gcp_existing_secret_name
  k8s_namespace   = kubernetes_namespace.mastodon.id
  k8s_secret_name = local.smtp_k8s_secret_name_from_gcp
  k8s_secret_key  = "password"
  depends_on      = [kubernetes_namespace.mastodon]
}

resource "helm_release" "mastodon" {
  name              = var.name
  namespace         = kubernetes_namespace.mastodon.id
  repository        = "./charts"
  chart             = "mastodon"
  dependency_update = true # TODO: Remove this once the public chart is updated
  version           = var.helm_chart_version
  timeout           = 600
  values            = trimspace(var.app_helm_additional_values) != "" ? [local.mastodon_release_helm_values, var.app_helm_additional_values] : [local.mastodon_release_helm_values]
  depends_on = [
    module.gke,
    module.sql_db
  ]
}

resource "kubectl_manifest" "gcp_managed_cert" {
  yaml_body = local.mastodon_gcp_managed_cert_manifest
  depends_on = [
    helm_release.mastodon
  ]
  override_namespace = kubernetes_namespace.mastodon.id
}


