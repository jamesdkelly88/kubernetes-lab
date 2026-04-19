locals {
  name    = lower(terraform.workspace)
  vm      = data.netbox_virtual_machines.lookup.vms[0]
  ip      = split("/", local.vm.primary_ip4)[0]
  context = jsondecode(local.vm.local_context_data)
}