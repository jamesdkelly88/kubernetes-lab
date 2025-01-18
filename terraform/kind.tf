resource "kind_cluster" "kind" {
    count                  = local.hosts[var.host].type == "kind" ? 1 : 0
    name                   = var.cluster
    node_image             = "kindest/node:v${ local.hosts[var.host].k8s_version }"
    wait_for_ready         = true

    kubeconfig_path        = pathexpand("~/.kube/${var.host}")

    kind_config {
        kind               = "Cluster"
        api_version        = "kind.x-k8s.io/v1alpha4"

        node {
          role             = "control-plane"

          dynamic "extra_port_mappings" {
                for_each = local.hosts[var.host].ports
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