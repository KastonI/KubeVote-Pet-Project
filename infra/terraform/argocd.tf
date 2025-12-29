resource "helm_release" "argocd" {
  namespace        = "argocd"
  create_namespace = true
  name             = "argocd"

  repository      = "https://argoproj.github.io/argo-helm"
  chart           = "argo-cd"
  version         = "9.2.1"
  atomic          = true
  cleanup_on_fail = true
  wait            = true

#  depends_on = [ module.eks ]

  values = [<<-YAML
#    global:
#      nodeSelector:
#        workload: system
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
        path           = "apps"
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