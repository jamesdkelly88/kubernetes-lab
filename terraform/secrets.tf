resource "akeyless_static_secret" "kubeconfig" {
  path  = "/k8s/config/${local.host.hostname}/kubeconfig"
  value = local.host.type == "kind" ? kind_cluster.kind[0].kubeconfig : null
}

resource "akeyless_static_secret" "talosconfig" {
  count = local.host.type == "kind" ? 0 : 1
  path  = "/k8s/config/${local.host.hostname}/talosconfig"
  value = null
}

data "akeyless_static_secret" "akeyless_id" {
  path = "/k8s/config/credentials/${local.host.secret}/user"
}

data "akeyless_static_secret" "akeyless_key" {
  path = "/k8s/config/credentials/${local.host.secret}/password"
}

data "akeyless_static_secret" "github_token" {
  path = "/k8s/config/credentials/github"
}