variable "argocd_admin_password_bcrypt" {
  description = "bcrypt hash for ArgoCD admin password"
  type        = string
  default     = null
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "domain" {
  type = string
}