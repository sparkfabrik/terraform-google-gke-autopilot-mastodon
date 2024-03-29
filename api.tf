
module "enabled_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "14.3.0"

  project_id                  = var.project_id
  disable_services_on_destroy = false

  activate_apis = [
    "iam.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "containerregistry.googleapis.com",
    "serviceusage.googleapis.com",
    "container.googleapis.com",
    "binaryauthorization.googleapis.com",
    "stackdriver.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudprofiler.googleapis.com",
    "redis.googleapis.com"
  ]
}
