variable "tfstate_access_key" {
  description = "TFState S3 access key"
  sensitive   = true
  type        = string
  default     = ""
}

variable "tfstate_secret_key" {
  description = "TFState S3 secret key"
  sensitive   = true
  type        = string
  default     = ""
}

variable "region" {
  type    = string
  default = "LON1"
}

variable "github_token" {
  description = "GitHub token"
  sensitive   = true
  type        = string
  default     = ""
}

variable "github_org" {
  description = "GitHub organization"
  type        = string
  default     = "NamelessPlanet"
}

variable "github_repository" {
  description = "GitHub repository"
  type        = string
  default     = "CloudNativeNow-Gitops"
}
