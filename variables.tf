# Description: Variables for the mastodon terraform module
variable "project_id" {
  type        = string
  description = "The GCP project id to install the P∏"
}

variable "name" {
  type        = string
  description = "Mastodon project name, it will be used as a prefix for all resources"
}

variable "domain" {
  type        = string
  description = "This is the unique identifier of your server in the network. It cannot be safely changed later, as changing it will cause remote servers to confuse your existing accounts with entirely new ones. It has to be the domain name you are running the server under (without the protocol part, e.g. just example.com)."
}

variable "region" {
  type        = string
  description = "The region to host the cluster in"
  default     = "europe-west1"
}

variable "helm_chart_version" {
  type        = string
  description = "The version of the helm chart to use"
  default     = "3.0.0"
}

variable "gcp_default_labels" {
  type        = map(string)
  description = "Default labels to apply to all resources"
  default     = null
}

variable "gke_datapath_provider" {
  type        = string
  description = "The GKE datapath provider to use"
  default     = "ADVANCED_DATAPATH"
}

variable "gke_maintenance_start_time" {
  type        = string
  description = "The start time for the maintenance window"
  default     = "1970-01-01T00:00:00Z"
}

variable "gke_maintenance_end_time" {
  type        = string
  description = "The end time for the maintenance window"
  default     = "1970-01-01T04:00:00Z"
}

variable "gke_maintenance_recurrence" {
  type        = string
  description = "The recurrence for the maintenance window"
  default     = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR,SA,SU"
}

variable "gke_authenticator_security_group" {
  type        = string
  description = "The security group to allow access to the cluster"
}

variable "gke_zone" {
  type        = list(any)
  description = "gke_zone within the region to use this cluster"
  default = [
    "europe-west1-b",
  ]
}

variable "kubernetes_namespace" {
  type        = string
  description = "The name of the namespace to deploy the application in"
  default     = "mastodon"
}

# Network.
variable "subnet_ip" {
  type        = string
  description = "The cidr range of the subnet"
  default     = "10.10.10.0/24"
}

# Storage.
variable "bucket_location" {
  type        = string
  description = "Bucket location"
}

variable "bucket_versioning" {
  description = "Enable bucket versioning"
  type        = bool
  default     = true
}

variable "bucket_force_destroy" {
  description = "Force destroy bucket"
  type        = bool
  default     = false
}

variable "bucket_storage_class" {
  description = "The Storage Class of the new bucket."
  type        = string
  default     = null
}

# Memorystore redis instance.
variable "memorystore_redis_enabled" {
  type        = bool
  description = "Enable memorystore redis"
  default     = true
}
variable "memorystore_redis_size" {
  type        = string
  description = "The size of the redis instance"
  default     = "1"
}
variable "memorystore_redis_tier" {
  type        = string
  description = "The tier of the redis instance"
  default     = "BASIC"
}

# Cloudsql
variable "cloudsql_zone" {
  type = string
}

variable "cloudsql_disk_size" {
  type        = number
  description = "The disk size for the master instance."
  default     = 10
}

variable "cloudsql_disk_type" {
  type        = string
  description = "The disk type for the master instance."
  default     = "PD_SSD"
}

variable "cloudsql_enable_backup" {
  type        = bool
  description = "Setup if postgres backup configuration is enabled.Default true"
  default     = true
}

variable "cloudsql_backup_start_time" {
  type        = string
  description = "HH:MM format time indicating when postgres backup configuration starts."
  default     = "02:00"
}

variable "cloudsql_backup_retained_count" {
  type        = number
  description = "Numeber of postgres backup to be retained. Default 30."
  default     = "30"
}

variable "cloudsql_deletion_protection" {
  type        = bool
  description = "Enable deletion protection for the cloudsql instance."
  default     = false
}

variable "cloudsql_tier" {
  type        = string
  description = "The tier of the master instance."
  default     = "db-g1-small"
}

variable "cloudsql_pgsql_version" {
  type        = string
  description = "value of the postgresql version"
  default     = "POSTGRES_14"
}

# Mastodon instance.
variable "app_keys" {
  type        = set(string)
  description = "Mastodon secret keys"
  default     = (["secret_key_base", "otp_secret", "vapid_private_key", "vapid_public_key"])
}

variable "app_create_admin" {
  type        = bool
  description = "Create admin account"
  default     = false
}

variable "app_admin_email" {
  type        = string
  description = "Admin email"
  default     = "not@localhost"
}

variable "app_admin_username" {
  type        = string
  description = "Admin username"
  default     = "not_gargron"
}

variable "app_locale" {
  type        = string
  description = "Mastodon locale"
  default     = "en"
}

variable "app_s3_existing_secret" {
  type        = string
  description = "S3 existing secret name"
  default     = null
}

variable "app_smtp_username" {
  type        = string
  description = "SMTP username"
  default     = null
}

variable "app_smtp_password" {
  type        = string
  description = "SMTP password"
  default     = null
  sensitive   = true
}

variable "app_smtp_existing_secret" {
  type        = string
  description = "SMTP existing secret name"
  default     = null
}

variable "app_existing_secret_name" {
  type        = string
  description = "Mastodon existing secret name"
  default     = null
}

variable "app_helm_additional_values" {
  type        = string
  description = "Additional values to pass to the helm"
  default     = ""
}
