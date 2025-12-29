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

  argocd_domain = "argocd.kastonl.live"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true


  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery"          = local.name
  }

  tags = local.tags
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.8.0"

  name               = local.name
  kubernetes_version = local.kubernetes_version

  # Gives Terraform identity admin access to cluster which will
  # allow deploying resources (Karpenter) into the cluster
  enable_cluster_creator_admin_permissions = true
  endpoint_public_access                   = true

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_groups = {
    karpenter = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 1
      desired_size = 1

      labels = {
        # Used to ensure Karpenter runs on nodes that it does not manage
        "karpenter.sh/controller" = "true"
        "workload"                = "system"
      }
    }
  }

  node_security_group_tags = merge(local.tags, {
    "karpenter.sh/discovery" = local.name
  })

  tags = local.tags
}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "21.8.0"

  cluster_name = module.eks.cluster_name

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_use_name_prefix   = false
  node_iam_role_name              = local.name
  create_pod_identity_association = true

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = local.tags
}

module "karpenter_disabled" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"
  create = false
}

resource "helm_release" "argocd" {
  namespace        = "argocd"
  create_namespace = true
  name             = "argocd"

  repository      = "https://argoproj.github.io/argo-helm"
  chart           = "argo-cd"
  version         = "9.2.1"
  atomic          = true
  cleanup_on_fail = true
  wait            = false

  depends_on = [ module.eks ]

  values = [<<-YAML
    global:
      nodeSelector:
        workload: system
    configs:
      cm:
        url: https://localhost:8080
      params:
        server.insecure: false

    server:
      service:
        type: ClusterIP

      ingress:
        enabled: false
  YAML
  ]

  # Values for local deploy in cluster without ingress
  # values = [<<-YAML
  #   server:
  #     service:
  #       type: ClusterIP
  #     ingress:
  #       enabled: false

  #   configs:
  #     params:
  #       server.insecure: true
  # YAML
  # ]

}

resource "kubernetes_manifest" "argocd_root_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "root"
      namespace = "argocd"
    }
    spec = {
      project = "default"

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }

      source = {
        repoURL        = "https://github.com/KastonI/KubeVote-Pet-Project.git"
        targetRevision = "master"
        path           = "k8s"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
  depends_on = [helm_release.argocd]
}



# resource "helm_release" "karpenter" {
#   namespace           = "kube-system"
#   name                = "karpenter"
#   repository          = "oci://public.ecr.aws/karpenter"
#   repository_username = data.aws_ecrpublic_authorization_token.token.user_name
#   repository_password = data.aws_ecrpublic_authorization_token.token.password
#   chart               = "karpenter"
#   version             = "1.8.2"
#   wait                = false

#   depends_on = [ module.eks ]

#   values = [
#     <<-EOT
#     nodeSelector:
#       karpenter.sh/controller: 'true'
#     dnsPolicy: Default
#     settings:
#       clusterName: ${module.eks.cluster_name}
#       clusterEndpoint: ${module.eks.cluster_endpoint}
#       interruptionQueue: ${module.karpenter.queue_name}
#     webhook:
#       enabled: false
#     EOT
#   ]
# }

# EC2NodeClass and NodePool