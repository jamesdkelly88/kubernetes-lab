resource "helm_release" "argocd" {
  count            = local.cluster.argocd == true ? 1 : 0
  depends_on       = [time_sleep.wait_for_cluster]
  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.7.16"
  create_namespace = true

  set = [
    {
      name  = "server.insecure"
      value = true
    },
    {
      name  = "server.service.type"
      value = "NodePort"
    },
    {
      name  = "server.service.nodePortHttp"
      value = "30001"
    }
  ]
}

data "kubernetes_secret" "argocd" {
  count      = local.cluster.argocd == true ? 1 : 0
  depends_on = [helm_release.argocd]
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}

resource "kubernetes_manifest" "argo-app" {
  count      = local.cluster.argocd == true ? 1 : 0
  depends_on = [helm_release.argocd]
  manifest   = provider::kubernetes::manifest_decode(file("../clusters/${var.cluster}/argocd/root-app.yaml"))
}