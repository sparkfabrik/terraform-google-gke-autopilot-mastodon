output "region" {
  value       = var.region
  description = "Mastodon cloud region"
}

output "bucket_name" {
  value       = google_storage_bucket.bucket.name
  description = "Mastodon bucket name"
}

output "bucket_service_account" {
  value       = google_service_account.service_account.email
  description = "Mastodon bucket service account"
}

output "k8s_bucket_secret_name" {
  value       = kubernetes_secret.s3_secret.id
  description = "Mastodon k8s bucket secret name"
}

output "mastodon_global_ip" {
  value       = google_compute_global_address.app_lb_ip.address
  description = "Mastodon global IP"
}

output "mastodon_cloud_nat_ip" {
  value       = google_compute_address.cloud_nat_ip.address
  description = "Mastodon cloud NAT IP"
}

output "gke_kubernetes_version" {
  value       = module.gke.master_version
  description = "Mastodon GKE kubernetes version"
}

output "gke_min_master_version" {
  value       = module.gke.min_master_version
  description = "Mastodon GKE min master version"
}

output "gke_service_account" {
  value       = module.gke.service_account
  description = "Mastodon GKE service account"
}

output "cluster_name" {
  value       = module.gke.name
  description = "Mastodon GKE cluster name"
}

output "cloudsql_instance_name" {
  value       = module.sql_db.instance_name
  description = "Mastodon CloudSQL DB instance name"
}
