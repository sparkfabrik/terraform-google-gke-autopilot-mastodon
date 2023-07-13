terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.73.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.73.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.22.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
  }
}
