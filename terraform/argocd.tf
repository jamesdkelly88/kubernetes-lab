resource "helm_release" "argocd" {
  count            = local.cluster.argocd == true ? 1 : 0
  depends_on       = [time_sleep.wait_for_cluster]
  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.8.7"
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

resource "time_sleep" "wait_for_argocd" {
  count      = local.cluster.argocd == true ? 1 : 0
  depends_on = [helm_release.argocd]

  create_duration = "2m"
}

data "kubernetes_secret" "argocd" {
  count      = local.cluster.argocd == true ? 1 : 0
  depends_on = [time_sleep.wait_for_argocd]
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}

resource "kubectl_manifest" "argo-app" {
  count      = local.cluster.argocd == true ? 1 : 0
  depends_on = [time_sleep.wait_for_argocd]
  yaml_body  = file("../clusters/${var.cluster}/argocd.yaml")
}