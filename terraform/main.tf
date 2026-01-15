data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  name               = "ex-${basename(dirname(path.cwd))}"
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

