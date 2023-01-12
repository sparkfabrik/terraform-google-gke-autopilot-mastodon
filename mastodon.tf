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
      MASTODON_SMTP_EXISTING_SECRET : var.app_smtp_existing_secret != null ? var.app_smtp_existing_secret : kubernetes_secret.mastodon_smtp_secret[0].metadata[0].name
      MASTODON_APP_EXISTING_SECRET_NAME : var.app_existing_secret_name != null ? var.app_existing_secret_name : kubernetes_secret.mastodon_secrets.metadata[0].name
      MASTODON_POSTGRES_HOST : module.sql_db.private_ip_address
      MASTODON_POSTGRES_USER : "mastodon"
      MASTODON_POSTGRES_DB : "mastodon"
      MASTODON_POSTGRES_SECRET_NAME : local.sql_k8s_secret_name
      MASTODON_GLOBAL_IP_NAME : local.mastodon_gcp_app_lb_ip_name
      MASTODON_REDIS_ENABLED : var.memorystore_redis_enabled ? "false" : "false"
      MASTODON_REDIS_HOSTNAME : var.memorystore_redis_enabled ? google_redis_instance.mastodon_redis[0].host : ""
      MASTODON_REDIS_SECRET_NAME : var.memorystore_redis_enabled ? kubernetes_secret.mastodon_memorystore_redis_secret[0].metadata[0].name : kubernetes_secret.mastodon_redis_secret[0].metadata[0].name
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
  secret_id = format("%s-%s", var.name, each.key)

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
resource "kubernetes_secret" "mastodon_memorystore_redis_secret" {
  count = var.memorystore_redis_enabled ? 1 : 0
  metadata {
    name      = local.redis_k8s_secret_name
    namespace = kubernetes_namespace.mastodon.id
  }
  data       = { redis-password = google_redis_instance.mastodon_redis[0].auth_string }
  depends_on = [kubernetes_namespace.mastodon]
}

resource "kubernetes_secret" "mastodon_redis_secret" {
  count = var.memorystore_redis_enabled ? 0 : 1
  metadata {
    name      = local.redis_k8s_secret_name
    namespace = kubernetes_namespace.mastodon.id
  }
  data       = { redis-password = random_password.mastodon_redis_secret_random[0].result }
  depends_on = [kubernetes_namespace.mastodon]
}

resource "random_password" "mastodon_redis_secret_random" {
  count   = var.memorystore_redis_enabled ? 0 : 1
  length  = 32
  special = false
}

resource "helm_release" "mastodon" {
  name              = var.name
  namespace         = kubernetes_namespace.mastodon.id
  repository        = "${path.module}/charts"
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

# Create smtp secret.
resource "kubernetes_secret" "mastodon_smtp_secret" {
  count = var.app_smtp_username != null && var.app_smtp_password != null ? 1 : 0
  metadata {
    name      = local.smtp_k8s_secret_name
    namespace = kubernetes_namespace.mastodon.id
  }
  data = {
    username = var.app_smtp_username
    password = var.app_smtp_password
  }
  depends_on = [kubernetes_namespace.mastodon]
}
