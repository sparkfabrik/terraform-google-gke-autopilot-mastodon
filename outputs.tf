output "bucket_name" {
  value       = google_storage_bucket.bucket.name
  description = "Mastodon bucket name"
}

output "service_account" {
  value       = google_service_account.service_account.email
  description = "Mastodon service account"
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
