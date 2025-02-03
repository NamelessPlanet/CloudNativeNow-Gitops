terraform {
  required_providers {
    civo = {
      source  = "civo/civo"
      version = "1.1.5"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
  }

  backend "s3" {
    endpoint                    = "https://objectstore.lon1.civo.com"
    bucket                      = "cloudnativenow-tfstate"
    key                         = "terraform.tfstate"
    region                      = var.region
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }

}
