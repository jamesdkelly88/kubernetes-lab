resource "kind_cluster" "kind" {
  count          = local.host.type == "kind" ? 1 : 0
  name           = var.cluster
  node_image     = "kindest/node:v${local.host.k8s_version}"
  wait_for_ready = true

  kubeconfig_path = pathexpand(local.kubeconfig)

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      dynamic "extra_port_mappings" {
        for_each = local.host.ports
        content {
          container_port = extra_port_mappings.value
          host_port      = extra_port_mappings.key
        }
      }
    }

    # node {
    #   role             = "worker"
    # }
  }
}

resource "null_resource" "remove_local_storage" {
  count      = local.host.type == "kind" ? 1 : 0
  depends_on = [time_sleep.wait_for_cluster]

  provisioner "local-exec" {
    command = "KUBECONFIG=${local.kubeconfig} kubectl delete -k ./remove-local-storage/"
  }
}