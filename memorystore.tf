resource "google_redis_instance" "fediverse_redis" {
  count              = var.memorystore_redis_enabled ? 1 : 0
  display_name       = "Fediverse Redis - ${var.name}"
  name               = "mastodon-redis-${var.name}"
  tier               = var.memorystore_redis_tier
  memory_size_gb     = var.memorystore_redis_size
  region             = var.region
  authorized_network = module.vpc.network_self_link
  auth_enabled       = true
  redis_configs = {
    "maxmemory-gb" = var.memorystore_redis_size * 0.8
  }
}

moved {
  from = google_redis_instance.mastodon_redis
  to   = google_redis_instance.fediverse_redis
}
