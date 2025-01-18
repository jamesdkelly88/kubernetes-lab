resource "flux_bootstrap_git" "this" {
  count              = local.clusters[var.cluster].fluxcd == true ? 1 : 0
  embedded_manifests = true
  path               = "clusters/${var.cluster}/fluxcd.yaml"

  depends_on = [ time_sleep.wait_for_cluster ]
}