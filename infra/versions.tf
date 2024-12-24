terraform {
  required_providers {
    civo = {
      source  = "civo/civo"
      version = "1.1.3"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.2"
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
    access_key                  = var.tfstate_access_key
    secret_key                  = var.tfstate_secret_key
  }

}
