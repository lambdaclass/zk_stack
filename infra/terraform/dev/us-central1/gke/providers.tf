terraform {
  required_version = ">= 1.9.0"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.35.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "5.58.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.14.0"
    }
  }

  backend "gcs" {
    bucket  = "zksync_terraform_state"
    prefix  = "dev/eks"
  }
}

provider "google" {
  project = "zksync-413615"
}

provider "aws" {
}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "helm" {
  kubernetes {
     host                   = "https://${module.gke.endpoint}"
     token                  = data.google_client_config.default.access_token
     cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}

data "google_client_config" "default" {}
