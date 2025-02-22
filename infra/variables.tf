variable "civo_api_key" {
  description = "Civo API key"
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
