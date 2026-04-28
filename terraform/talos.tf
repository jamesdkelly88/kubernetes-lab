resource "talos_machine_secrets" "this" {
  talos_version = local.context.talos_version
}

data "talos_machine_configuration" "this" {
  cluster_name       = local.context.cluster
  machine_type       = "controlplane"
  cluster_endpoint   = "https://${local.ip}:6443"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = local.context.kubernetes_version
  talos_version      = local.context.talos_version
}

data "talos_client_configuration" "this" {
  cluster_name         = local.context.cluster
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = [local.ip]
}

resource "talos_machine_configuration_apply" "this" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = local.ip
  config_patches              = local.patches
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.this
  ]
  node                 = local.ip
  client_configuration = talos_machine_secrets.this.client_configuration

}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.ip
}