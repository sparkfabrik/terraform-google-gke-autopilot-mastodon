variable "name" {
  type        = string
  description = "Peertube project name, it will be used as a prefix for all resources"
}

variable "region" {
  type        = string
  description = "The region to host the cluster in"
}

variable "project_id" {
  type        = string
  description = "The project ID to deploy to"
}

variable "cloudsql_instance_name" {
  type        = string
  description = "The name of the Cloud SQL instance to connect to"
}

variable "bucket_location" {
  type        = string
  description = "The location of the bucket."
  default     = null
}

variable "bucket_force_destroy" {
  type        = bool
  description = "Whether to allow the bucket to be destroyed when deleting the terraform resource."
  default     = false
}

variable "bucket_versioning" {
  type        = bool
  description = "Whether versioning should be enabled for the bucket."
  default     = true
}

variable "peertube_buckets" {
  type = list(object({
    name          = string
    location      = string
    storage_class = string
  }))
  description = "List of buckets to create"
  default = [
    {
      name          = "web-videos"
      location      = null
      storage_class = null
    },
    {
      name          = "hls-videos"
      location      = null
      storage_class = null
    }
  ]
}

variable "kubernetes_namespace" {
  type        = string
  description = "The Kubernetes namespace to deploy to"
  default     = "peertube"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster to deploy to"
}
