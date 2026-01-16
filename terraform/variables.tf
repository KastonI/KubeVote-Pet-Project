variable "argocd_admin_password_bcrypt" {
  description = "bcrypt hash for ArgoCD admin password"
  type        = string
  default     = null
}

variable "aws_region" {
  description = "AWS region where infrastructure resources will be created"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token with permissions to manage DNS records and tunnel"
  type      = string
  sensitive = true
}

variable "domain" {
  description = "Domain name used for DNS records and service endpoints"
  type = string
}