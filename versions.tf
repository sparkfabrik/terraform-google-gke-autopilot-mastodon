terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source = "hashicorp/google"
      # Cause this bug: https://github.com/hashicorp/terraform-provider-google/issues/12804
      version = "~> 4.39.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.48.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}
