locals {
  name           = lower(terraform.workspace)
  vm             = data.netbox_virtual_machines.lookup.vms[0]
  ip             = split("/", local.vm.primary_ip4)[0]
  context        = jsondecode(local.vm.local_context_data)
  bws_project_id = "15e59f8f-30ab-4415-bf66-b31c007af2e6"
  schematic_id   = "613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245"

  cluster = {
    host                   = data.talos_machine_configuration.this.cluster_endpoint
    client_certificate     = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
    cluster_ca_certificate = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
  }
}