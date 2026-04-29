resource "helm_release" "flux" {
  name             = "flux"
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  version          = "2.18.3"
  namespace        = "flux-system"
  create_namespace = true
}

resource "time_sleep" "wait_for_flux" {
  depends_on      = [helm_release.flux]
  create_duration = "2m"
}

resource "kubernetes_manifest" "repo" {
  depends_on = [time_sleep.wait_for_flux]
  manifest = {
    apiVersion = "source.toolkit.fluxcd.io/v1"
    kind       = "GitRepository"
    metadata = {
      name      = "github"
      namespace = "flux-system"
    }
    spec = {
      interval = "1m0s"
      ref = {
        branch = local.context.branch
      }
      url = "https://github.com/jamesdkelly88/kubernetes-lab"
    }
  }
}

resource "kubernetes_manifest" "kustomize" {
  depends_on = [kubernetes_manifest.repo]
  manifest = {
    apiVersion = "kustomize.toolkit.fluxcd.io/v1"
    kind       = "Kustomization"
    metadata = {
      name      = local.context.cluster
      namespace = "flux-system"
    }
    spec = {
      interval = "10m0s"
      path     = "./cluster/${local.context.cluster}"
      prune    = true
      sourceRef = {
        kind = "GitRepository"
        name = "github"
      }
    }
  }
}