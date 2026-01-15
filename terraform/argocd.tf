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
  # depends_on      = [helm_release.karpenter]

  set_sensitive = var.argocd_admin_password_bcrypt != null ? [{
    name  = "configs.secret.argocdServerAdminPassword"
    value = var.argocd_admin_password_bcrypt
  }] : []

  set = var.argocd_admin_password_bcrypt != null ? [{
    name  = "configs.secret.argocdServerAdminPasswordMtime"
    value = "bootstrap"
  }] : []

  lifecycle {
    ignore_changes = [set_sensitive, set]
  }

  values = [file("${path.root}/../argocd/argocd-values.yaml")]
}

resource "kubectl_manifest" "argocd_root_app" {
  depends_on = [helm_release.argocd]
  yaml_body  = file("${path.root}/../argocd/root-of-app.yaml")
}