variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "argocd_admin_password_bcrypt" {
  description = "Password to ArgoCd"
  type = string
}

variable "cloudflare_api_token"  {
  type = string
  sensitive = true
}

variable "cloudflare_account_id" {
  type = string
  sensitive = true
  default = "21d5f7467434911098b83ab93752b470"
}

variable "domain" {
  type = string
}