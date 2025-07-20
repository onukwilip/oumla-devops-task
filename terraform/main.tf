terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "terraform-state-k8s-cluster-oumla-kubernetes"
    prefix = "k8s-cluster/terraform.tfstate"
  }
}

provider "google" {
  # Configuration options
  project = var.project_id
  region  = var.region
}

