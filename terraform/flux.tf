resource "flux_bootstrap_git" "this" {
  count              = local.cluster.fluxcd == true ? 1 : 0
  embedded_manifests = true
  path               = "clusters/${var.cluster}/flux"

  depends_on = [time_sleep.wait_for_cluster]
}