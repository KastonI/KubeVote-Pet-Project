data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "http" "ip" {
  url = "https://ifconfig.me/ip"
}

locals {
  name               = "ex-KubeVote"
  kubernetes_version = "1.34"
  region             = var.aws_region

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Project   = local.name
    DevOps    = "KastonL"
    ManagedBy = "Terraform"
    GithubOrg = "terraform-aws-modules"
  }
}

