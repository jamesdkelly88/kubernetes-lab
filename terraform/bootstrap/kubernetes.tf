resource "kubernetes_namespace" "external-secrets" {
  metadata {
    name = "external-secrets"
  }
}

resource "kubernetes_secret" "example" {
  metadata {
    name = "akeyless-secret-creds"
    namespace = "external-secrets"
  }

  data = {
    accessId = data.akeyless_static_secret.akeyless_id.value
    accessType = "api_key"
    accessTypeParam = data.akeyless_static_secret.akeyless_key.value
  }

  type = "kubernetes.io/generic"

  depends_on = [ kubernetes_namespace.external-secrets ]
}