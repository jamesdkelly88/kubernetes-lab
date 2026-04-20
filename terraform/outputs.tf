output "ip_address" {
  value = local.ip
}

# output "vm" {
#   value = local.vm
# }

output "cluster" {
  value = local.context.cluster
}

output "kubernetes_version" {
  value = local.context.kubernetes_version
}

output "talos_version" {
  value = local.context.talos_version
}
resource "local_file" "machine_configuration" {
  content  = talos_machine_configuration_apply.this.machine_configuration
  filename = "config.yml"
}

resource "local_file" "kubeconfig" {
  content  = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = "kubeconfig"

}

resource "local_file" "talosconfig" {
  content = templatefile("${path.module}/talosconfig.tpl", {
    ip  = local.ip
    ca  = data.talos_client_configuration.this.client_configuration.ca_certificate
    crt = data.talos_client_configuration.this.client_configuration.client_certificate
    key = data.talos_client_configuration.this.client_configuration.client_key
  })
  filename = "talosconfig"
}