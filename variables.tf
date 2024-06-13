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

variable "gcp_default_labels" {
  type        = map(string)
  description = "Default labels to apply to all resources"
  default     = null
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

variable "gke_kubernetes_version" {
  type        = string
  description = "The Kubernetes version of the masters. If set to 'latest' it will pull latest available version in the selected region."
  default     = "latest"
}

variable "gke_workload_config_audit_mode" {
  type        = string
  description = "The mode for workload identity config audit"
  default     = ""
}

variable "gke_workload_vulnerability_mode" {
  type        = string
  description = "The mode for workload identity vulnerability"
  default     = ""
}

variable "gke_create_service_account" {
  type        = bool
  description = "Defines if service account specified to run nodes should be created."
  default     = true
}

variable "gke_service_account" {
  type        = string
  description = "The service account to run nodes as if not overridden in node_pools. The gke_create_service_account variable default value (true) will cause a cluster-specific service account to be created. This service account should already exists and it will be used by the node pools. If you wish to only override the service account name, you can use service_account_name variable."
  default     = ""
}

variable "gke_service_account_name" {
  type        = string
  description = "The name of the service account that will be created if gke_create_service_account is true. If you wish to use an existing service account, use gke_service_account variable."
  default     = ""
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
variable "mastodon_keys" {
  type        = set(string)
  description = "Mastodon secret keys"
  default     = (["secret_key_base", "otp_secret"])
}

variable "mastodon_create_admin" {
  type        = bool
  description = "Create admin account"
  default     = false
}

variable "mastodon_admin_email" {
  type        = string
  description = "Admin email"
  default     = "not@localhost"
}

variable "mastodon_admin_username" {
  type        = string
  description = "Admin username"
  default     = "not_gargron"
}

variable "mastodon_locale" {
  type        = string
  description = "Mastodon locale"
  default     = "en"
}

variable "mastodon_s3_existing_secret" {
  type        = string
  description = "S3 existing secret name"
  default     = null
}

variable "mastodon_smtp_username" {
  type        = string
  description = "SMTP username"
  default     = null
}

variable "mastodon_smtp_password" {
  type        = string
  description = "SMTP password"
  default     = null
  sensitive   = true
}

variable "mastodon_smtp_existing_secret" {
  type        = string
  description = "SMTP existing secret name"
  default     = null
}

variable "mastodon_existing_secret_name" {
  type        = string
  description = "Mastodon existing secret name"
  default     = null
}

variable "mastodon_vapid_public_key" {
  type        = string
  description = "Mastodon vapid public key"
  default     = null
}

variable "mastodon_vapid_private_key" {
  type        = string
  description = "Mastodon vapid private key"
  default     = null
}

variable "mastodon_helm_additional_values" {
  type        = string
  description = "Additional values to pass to the helm"
  default     = ""
}
