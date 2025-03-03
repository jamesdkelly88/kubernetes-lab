locals {
  hosts = {
    local1 = {
      hostname    = "localhost"
      ip_address  = "127.0.0.1"
      dns_domain  = "jklocal.duckdns.org"
      # renovate: datasource=github-releases depName=kubernetes/kubernetes
      k8s_version = "1.31.0"
      ports = {
        80    = 80
        443   = 443
        30000 = 30000
      }
      secret = "local"
      type   = "kind"
    }
    local2 = {
      hostname    = "localhost2"
      ip_address  = "127.0.0.1"
      dns_domain  = "jklocal.duckdns.org"
      # renovate: datasource=github-releases depName=kubernetes/kubernetes
      k8s_version = "1.30.0"
      ports = {
        8080  = 80
        8443  = 443
        31000 = 30000
        31001 = 30001
      }
      secret = "local"
      type   = "kind"
    }
  }

  clusters = {
    alpha = {
      argocd = false
      fluxcd = true
      branch = "main"
      host   = "local1"
    }
    beta = {
      argocd = true
      fluxcd = false
      branch = "main"
      host   = "local2"
    }
  }

  cluster    = local.clusters[var.cluster]
  host       = local.hosts[local.cluster.host]
  kubeconfig = "~/.kube/${local.cluster.host}"
}