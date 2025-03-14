resource "akeyless_static_secret" "kubeconfig" {
  path  = "/k8s/config/${local.host.hostname}/kubeconfig"
  value = local.host.type == "kind" ? kind_cluster.kind[0].kubeconfig : null
}

resource "akeyless_static_secret" "talosconfig" {
  count = local.host.type == "kind" ? 0 : 1
  path  = "/k8s/config/${local.host.hostname}/talosconfig"
  value = null
}

resource "akeyless_static_secret" "argocd" {
  count = local.cluster.argocd == true ? 1 : 0
  path  = "/k8s/config/${local.host.hostname}/argocd"
  value = data.kubernetes_secret.argocd[0].data.password
}

data "akeyless_static_secret" "akeyless_id" {
  path = "/k8s/config/credentials/${local.host.secret}/user"
}

data "akeyless_static_secret" "akeyless_key" {
  path = "/k8s/config/credentials/${local.host.secret}/password"
}