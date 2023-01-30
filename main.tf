locals {
  gcp_default_labels = var.gcp_default_labels != null ? var.gcp_default_labels : {
    "project" = var.name
  }
  smtp_k8s_secret_name_from_gcp = format("%s-%s", replace(var.name, "_", "-"), "mastodon-smtp-secret")
  s3_k8s_secret_name            = format("%s-%s", replace(var.name, "_", "-"), "mastodon-s3-secret")
  sql_k8s_secret_name           = format("%s-%s", replace(var.name, "_", "-"), "mastodon-postgres-pwd")
  sql_mtls_k8s_secret_name      = format("%s-%s", replace(var.name, "_", "-"), "mastodon-postgres-mtls")
  redis_k8s_secret_name         = format("%s-%s", replace(var.name, "_", "-"), "mastodon-redis")
  mastodon_k8s_secret_name      = format("%s-%s", replace(var.name, "_", "-"), "mastodon-keys")
  mastodon_gcp_app_lb_ip_name   = "${var.name}-app-lb-ip"
}

module "gke" {
  source                          = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  version                         = "24.1.0"
  project_id                      = var.project_id
  name                            = "${var.name}-gke"
  region                          = var.region
  zones                           = var.zones
  network                         = module.vpc.network_name
  subnetwork                      = module.vpc.subnets_names[0]
  ip_range_pods                   = element(module.vpc.subnets_secondary_ranges[0][*].range_name, 0)
  ip_range_services               = element(module.vpc.subnets_secondary_ranges[0][*].range_name, 1)
  maintenance_start_time          = var.gke_maintenance_start_time
  maintenance_end_time            = var.gke_maintenance_end_time
  maintenance_recurrence          = var.gke_maintenance_recurrence
  datapath_provider               = var.gke_datapath_provider
  authenticator_security_group    = var.authenticator_security_group
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
