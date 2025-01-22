resource "time_sleep" "wait_for_cluster" {
  depends_on = [kind_cluster.kind]

  create_duration = "2m"
}

resource "kubernetes_namespace" "external-secrets" {
  metadata {
    name = "external-secrets"
  }

  depends_on = [time_sleep.wait_for_cluster]
}

resource "kubernetes_secret" "akeyless-external-secret" {
  metadata {
    name      = "akeyless-secret-creds"
    namespace = "external-secrets"
  }

  data = {
    accessId        = data.akeyless_static_secret.akeyless_id.value
    accessType      = "api_key"
    accessTypeParam = data.akeyless_static_secret.akeyless_key.value
  }

  type = "kubernetes.io/generic"

  depends_on = [kubernetes_namespace.external-secrets]
}