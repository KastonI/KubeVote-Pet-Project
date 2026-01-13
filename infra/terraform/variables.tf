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

variable "cloudflare_account_id" {
  type      = string
  sensitive = true
}

variable "domain" {
  type = string
}





############ TEST #############

variable "aws_key" {
  default = "AKIA123456e8Af234"
}

variable "aws_secret" {
  default = "abcdEFGHijklMNOPqrstUVWXyz0123w56789abcd"
}