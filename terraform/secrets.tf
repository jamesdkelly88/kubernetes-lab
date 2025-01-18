resource "akeyless_static_secret" "kubeconfig" {
  path = "/k8s/config/${ local.hosts[var.host].hostname }/kubeconfig"
  value = substr(var.host,0,5) == "local" ? kind_cluster.kind[0].kubeconfig : null
}

resource "akeyless_static_secret" "talosconfig" {
  count = substr(var.host,0,5) == "local" ? 0 : 1
  path = "/k8s/config/${ local.hosts[var.host].hostname }/talosconfig"
  value = null
}

data "akeyless_static_secret" "akeyless_id" {
  path = "/k8s/config/credentials/${ local.hosts[var.host].secret }/user"
}

data "akeyless_static_secret" "akeyless_key" {
  path = "/k8s/config/credentials/${ local.hosts[var.host].secret }/password"
}
