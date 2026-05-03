resource "helm_release" "flux" {
  name             = "flux"
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  version          = "2.18.3"
  namespace        = "flux-system"
  create_namespace = true
  depends_on       = [time_sleep.wait_for_cluster]
}

resource "time_sleep" "wait_for_flux" {
  depends_on      = [helm_release.flux]
  create_duration = "2m"
}

resource "k8sconnect_object" "flux_repo" {
  yaml_body = templatefile("${path.module}/templates/gitrepository.tpl", {
    name      = "github"
    namespace = "flux-system"
    branch    = local.context.branch
    url       = "https://github.com/jamesdkelly88/kubernetes-lab"
  })
  cluster    = local.cluster
  depends_on = [time_sleep.wait_for_flux]
}

resource "k8sconnect_object" "flux_kustomize" {
  yaml_body = templatefile("${path.module}/templates/kustomization.tpl", {
    name       = local.context.cluster
    path       = "./cluster/${local.context.cluster}"
    repository = "github"
  })
  cluster    = local.cluster
  depends_on = [k8sconnect_object.flux_repo]
}
