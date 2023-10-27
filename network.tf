module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 7.5.0"
  network_name = "${var.name}-vpc"
  project_id   = module.enabled_google_apis.project_id
  routing_mode = "GLOBAL"
  subnets = [
    {
      subnet_name           = "mastodon-subnet"
      subnet_ip             = var.subnet_ip
      subnet_region         = var.region
      subnet_private_access = true
    }
  ]
  secondary_ranges = {
    "mastodon-subnet" = [
      {
        range_name    = "ip-range-pods"
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = "ip-range-services"
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}

resource "google_compute_address" "cloud_nat_ip" {
  name    = "${var.name}-cloud-nat-ip"
  region  = var.region
  project = var.project_id
}

module "cloud_nat" {
  source            = "terraform-google-modules/cloud-nat/google"
  version           = "~> 2.2.1"
  name              = "${var.name}-cloud-nat"
  project_id        = module.enabled_google_apis.project_id
  region            = var.region
  router            = format("%s-router", var.project_id)
  network           = module.vpc.network_self_link
  log_config_enable = true
  log_config_filter = "ERRORS_ONLY"
  nat_ips = [
    google_compute_address.cloud_nat_ip.self_link,
  ]
  create_router    = true
  min_ports_per_vm = "4096"
  depends_on = [
    google_compute_address.cloud_nat_ip,
  ]
}

resource "google_compute_global_address" "app_lb_ip" {
  name    = local.mastodon_gcp_app_lb_ip_name
  project = var.project_id
}
