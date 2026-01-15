# variable "env" {
#   type = string
#   validation {
#     condition     = contains(["local", "eks"], var.env)
#     error_message = "env must be local or eks"
#   }
# }

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