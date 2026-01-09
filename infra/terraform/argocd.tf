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
  #  depends_on = [ module.eks ]

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

resource "kubectl_manifest" "argocd_root_app" {
  depends_on = [helm_release.argocd]
  yaml_body  = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root
  namespace: argocd
spec:
  project: default
  destination:
    server: https://kubernetes.default.svc
    namespace: default

  source:
    repoURL: https://github.com/KastonI/KubeVote-Pet-Project.git
    targetRevision: gitops
    path: apps

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
YAML
}