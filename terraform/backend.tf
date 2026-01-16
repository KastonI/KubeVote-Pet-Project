terraform {
  backend "s3" {
    bucket       = "terraform-state-kubevote"
    key          = "envs/prod/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
  }
}

