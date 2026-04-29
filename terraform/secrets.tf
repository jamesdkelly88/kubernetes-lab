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

resource "time_sleep" "wait_for_cluster" {
  depends_on = [talos_cluster_kubeconfig.this]

  create_duration = "3m"
}

resource "kubernetes_namespace_v1" "external-secrets" {
  metadata {
    name = "external-secrets"
  }
  depends_on = [time_sleep.wait_for_cluster]
}

resource "kubernetes_secret_v1" "bws" {
  metadata {
    name      = "bitwarden-access-token"
    namespace = "external-secrets"
  }
  data = {
    token = data.bitwarden-secrets_secret.secrets["bws"].value
  }
  type       = "kubernetes.io/generic"
  depends_on = [kubernetes_namespace_v1.external-secrets]
}