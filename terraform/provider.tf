provider "aws" {
  region = local.region
}

# provider "helm" {
#   kubernetes = {
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

#     exec = {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       command     = "aws"
#       args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#     }
#   }
# }

# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#   }
# }

# provider "kubectl" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#   }
#   load_config_file = false
# }

provider "argocd" {
  core = true
}

#For test in local environment chose youre kubeconfig file
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kubernetes-admin@kubernetes"
}

provider "kubectl" {
  load_config_file = true
}





provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.15"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "~> 7.12"
    }
  }
}