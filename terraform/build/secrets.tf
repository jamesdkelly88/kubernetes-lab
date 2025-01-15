resource "akeyless_static_secret" "kubeconfig" {
  path = "/k8s/config/${ local.hosts[var.host].hostname }/kubeconfig"
  value = var.host == "local" ? kind_cluster.kind[0].kubeconfig : null
}

resource "akeyless_static_secret" "talosconfig" {
  count = var.host == "local" ? 0 : 1
  path = "/k8s/config/${ local.hosts[var.host].hostname }/talosconfig"
  value = null
}