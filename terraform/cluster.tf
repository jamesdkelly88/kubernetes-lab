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

resource "kubernetes_secret" "bws" {
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