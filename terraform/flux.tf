data "http" "flux" {
  url = "https://github.com/fluxcd/flux2/releases/latest/download/install.yaml"
}

data "kubectl_file_documents" "flux_install" {
  content = local.cluster.fluxcd == true ? data.http.flux.response_body : ""
}

resource "kubectl_manifest" "flux_install" {
  depends_on = [time_sleep.wait_for_cluster]
  for_each   = data.kubectl_file_documents.flux_install.manifests
  yaml_body  = each.value
}

resource "time_sleep" "wait_for_fluxcd" {
  count      = local.cluster.fluxcd == true ? 1 : 0
  depends_on = [kubectl_manifest.flux_install]

  create_duration = "2m"
}

data "kustomization" "flux_setup" {
  path = "../clusters/${var.cluster}/flux/cluster"
}

resource "kustomization_resource" "flux_setup" {
  depends_on = [time_sleep.wait_for_fluxcd]

  for_each = local.cluster.fluxcd == true ? data.kustomization.flux_setup.ids : []
  manifest = data.kustomization.flux_setup.manifests[each.value]
}