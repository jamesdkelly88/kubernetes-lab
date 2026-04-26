resource "bitwarden-secrets_secret" "talosconfig" {
  key = "talosconfig/${local.name}"
  value = templatefile("${path.module}/talosconfig.tpl", {
    ip  = local.ip
    ca  = data.talos_client_configuration.this.client_configuration.ca_certificate
    crt = data.talos_client_configuration.this.client_configuration.client_certificate
    key = data.talos_client_configuration.this.client_configuration.client_key
  })
  project_id = local.bws_project_id
}

resource "bitwarden-secrets_secret" "kubeconfig" {
  key        = "kubeconfig/${local.name}"
  value      = talos_cluster_kubeconfig.this.kubeconfig_raw
  project_id = local.bws_project_id
}