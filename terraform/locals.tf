locals {
  name           = lower(terraform.workspace)
  vm             = data.netbox_virtual_machines.lookup.vms[0]
  ip             = split("/", local.vm.primary_ip4)[0]
  context        = jsondecode(local.vm.local_context_data)
  bws_project_id = "15e59f8f-30ab-4415-bf66-b31c007af2e6"
}