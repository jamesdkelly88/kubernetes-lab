resource "bitwarden-secrets_secret" "talosconfig" {
  key = "talosconfig/${local.name}"
  value = templatefile("${path.module}/templates/talosconfig.tpl", {
    ip   = local.ip
    name = local.name
    ca   = data.talos_client_configuration.this.client_configuration.ca_certificate
    crt  = data.talos_client_configuration.this.client_configuration.client_certificate
    key  = data.talos_client_configuration.this.client_configuration.client_key
  })
  project_id = local.bws_project_id
}

resource "bitwarden-secrets_secret" "kubeconfig" {
  key        = "kubeconfig/${local.name}"
  value      = talos_cluster_kubeconfig.this.kubeconfig_raw
  project_id = local.bws_project_id
}

resource "time_sleep" "wait_for_cluster" {
  depends_on      = [talos_cluster_kubeconfig.this]
  create_duration = "3m"
}

resource "k8sconnect_object" "external_secrets_ns" {
  yaml_body = templatefile("${path.module}/templates/namespace.tpl", {
    name = "external-secrets"
  })
  cluster    = local.cluster
  depends_on = [time_sleep.wait_for_cluster]
}

resource "k8sconnect_object" "bws_secret" {
  yaml_body = templatefile("${path.module}/templates/secret.tpl", {
    name      = "bitwarden-access-token"
    namespace = "external-secrets"
    data = [
      {
        key   = "token",
        value = data.bitwarden-secrets_secret.secrets["bws"].value
      }
    ]
  })
  cluster    = local.cluster
  depends_on = [k8sconnect_object.external_secrets_ns]
}
