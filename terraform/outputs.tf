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
# resource "local_file" "machine_configuration" {
#   content  = talos_machine_configuration_apply.this.machine_configuration
#   filename = "config.yml"
# }