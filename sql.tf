resource "google_compute_global_address" "mastodon_sql" {
  provider      = google-beta
  project       = var.project_id
  name          = "${var.name}-sql-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  network       = module.vpc.network_self_link
  prefix_length = 16
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta
  network                 = module.vpc.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.mastodon_sql.name]
  depends_on              = [module.enabled_google_apis.project_id]
}

module "sql_db" {
  source              = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version             = "16.1.0"
  name                = "${var.name}-db"
  database_version    = var.cloudsql_pgsql_version
  project_id          = var.project_id
  region              = var.region
  zone                = var.cloudsql_zone
  tier                = var.cloudsql_tier
  deletion_protection = var.cloudsql_deletion_protection
  disk_size           = var.cloudsql_disk_size
  disk_type           = var.cloudsql_disk_type
  ip_configuration = {
    ipv4_enabled        = false
    private_network     = module.vpc.network_self_link
    require_ssl         = false
    allocated_ip_range  = null
    authorized_networks = []
  }
  backup_configuration = {
    enabled                        = var.cloudsql_enable_backup
    start_time                     = var.cloudsql_backup_start_time
    point_in_time_recovery_enabled = true
    retained_backups               = var.cloudsql_backup_retained_count
    location                       = null
    retention_unit                 = null
    transaction_log_retention_days = null
  }
  maintenance_window_day          = 7
  maintenance_window_hour         = 2
  maintenance_window_update_track = "stable"
  user_labels                     = local.gcp_default_labels
  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    module.enabled_google_apis.project_id,
  ]
}

resource "google_sql_user" "mastodon_sql_user" {
  name     = "mastodon"
  instance = module.sql_db.instance_name
  password = module.mastodon_db_pass.secret_value
}

resource "google_sql_database" "mastodon_sql_database" {
  name     = "mastodon"
  instance = module.sql_db.instance_name
}

# TODO: Make a PR to this module as it automatically prefixes the secret name with "-gitlab-"
module "mastodon_db_pass" {
  source          = "sparkfabrik/gke-gitlab/sparkfabrik//modules/secret_manager"
  version         = "2.17.1"
  project         = var.project_id
  region          = var.region
  secret_id       = ""
  k8s_namespace   = kubernetes_namespace.mastodon.id
  k8s_secret_name = local.sql_k8s_secret_name
  k8s_secret_key  = "password"
  depends_on      = [kubernetes_namespace.mastodon]
}

resource "kubernetes_secret" "postgresql_mtls_secret" {
  metadata {
    name      = local.sql_mtls_k8s_secret_name
    namespace = kubernetes_namespace.mastodon.id
  }
  data = {
    cert           = google_sql_ssl_cert.postgres_client_cert.cert
    private_key    = google_sql_ssl_cert.postgres_client_cert.private_key
    server_ca_cert = google_sql_ssl_cert.postgres_client_cert.server_ca_cert
  }
  depends_on = [kubernetes_namespace.mastodon]
}

resource "google_sql_ssl_cert" "postgres_client_cert" {
  common_name = "${var.name}.${var.domain}"
  instance    = module.sql_db.instance_name
  project     = var.project_id
}
