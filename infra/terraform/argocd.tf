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
  timeout         = 600
  depends_on      = [helm_release.karpenter]

  set_sensitive = [{
    name  = "configs.secret.argocdServerAdminPassword"
    value = var.argocd_admin_password_bcrypt
  }]

  set = [{
    name  = "configs.secret.argocdServerAdminPasswordMtime"
    value = "2026-01-04T00:00:00Z"
  }]

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

resource "argocd_application" "root_of_app" {
  metadata {
    name      = "root"
    namespace = "argocd"
  }
  spec {
    project = "default"

    source {
      repo_url        = "https://github.com/KastonI/KubeVote-Pet-Project.git"
      target_revision = "master"
      path            = "apps"
    }
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "default"
    }
    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
      sync_options = ["CreateNamespace=true"]
    }
  }
}