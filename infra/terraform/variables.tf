variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "argocd_admin_password_bcrypt" {
  description = "Password to ArgoCd"
  type = string
}