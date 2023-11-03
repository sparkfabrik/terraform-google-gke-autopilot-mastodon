locals {
  gcp_default_labels = var.gcp_default_labels != null ? var.gcp_default_labels : {
    "project" = var.name
  }
  s3_k8s_secret_name          = format("%s-%s", replace(var.name, "_", "-"), "mastodon-s3-secret")
  sql_k8s_secret_name         = format("%s-%s", replace(var.name, "_", "-"), "mastodon-postgres-pwd")
  sql_mtls_k8s_secret_name    = format("%s-%s", replace(var.name, "_", "-"), "mastodon-postgres-mtls")
  smtp_k8s_secret_name        = format("%s-%s", replace(var.name, "_", "-"), "mastodon-smtp")
  redis_k8s_secret_name       = format("%s-%s", replace(var.name, "_", "-"), "mastodon-redis")
  mastodon_k8s_secret_name    = format("%s-%s", replace(var.name, "_", "-"), "mastodon-keys")
  mastodon_gcp_app_lb_ip_name = "${var.name}-app-lb-ip"
}

module "gke" {
  source                          = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  version                         = "~> 29.0.0"
  project_id                      = var.project_id
  name                            = "${var.name}-gke"
  region                          = var.region
  zones                           = var.gke_zone
  network                         = module.vpc.network_name
  subnetwork                      = module.vpc.subnets_names[0]
  ip_range_pods                   = element(module.vpc.subnets_secondary_ranges[0][*].range_name, 0)
  ip_range_services               = element(module.vpc.subnets_secondary_ranges[0][*].range_name, 1)
  maintenance_start_time          = var.gke_maintenance_start_time
  maintenance_end_time            = var.gke_maintenance_end_time
  maintenance_recurrence          = var.gke_maintenance_recurrence
  authenticator_security_group    = var.gke_authenticator_security_group
  kubernetes_version              = var.gke_kubernetes_version
  workload_config_audit_mode      = var.gke_workload_config_audit_mode
  workload_vulnerability_mode     = var.gke_workload_vulnerability_mode
  create_service_account          = var.gke_create_service_account
  service_account_name            = var.gke_service_account_name
  service_account                 = var.gke_service_account
  horizontal_pod_autoscaling      = true
  enable_private_endpoint         = false
  enable_private_nodes            = true
  enable_vertical_pod_autoscaling = true
  enable_cost_allocation          = true
  cluster_resource_labels         = local.gcp_default_labels
}

resource "kubernetes_namespace" "mastodon" {
  provider = kubernetes
  metadata {
    name = var.kubernetes_namespace
  }
  depends_on = [module.gke]
}
