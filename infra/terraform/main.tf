data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_ecrpublic_authorization_token" "token" {
  region = "us-east-1"
}

locals {
  name               = "ex-${basename(dirname(dirname(path.cwd)))}"
  kubernetes_version = "1.34"
  region             = "eu-central-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Project   = local.name
    DevOps    = "KastonL"
    ManagedBy = "Terraform"
    GithubOrg = "terraform-aws-modules"
  }
}

