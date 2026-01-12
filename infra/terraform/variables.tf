variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "argocd_admin_password_bcrypt" {
  description = "Password to ArgoCd"
  type        = string
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "domain" {
  type = string
}