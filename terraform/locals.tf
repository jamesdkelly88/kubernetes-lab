locals {
  hosts = {
    local = {
        hostname = "localhost"
        ip_address = "127.0.0.1"
        dns_domain = "jklocal.duckdns.org"
        k8s_version = "1.31.0"
        ports = {
          80 = 80
          443 = 443
          30000 = 30000
          30001 = 30001
          
        }
        secret = "local"
        type = "kind"
    }
    local2 = {
        hostname = "localhost2"
        ip_address = "127.0.0.1"
        dns_domain = "jklocal.duckdns.org"
        k8s_version = "1.30.0"
        ports = {
          8080 = 80
          8443 = 443
        }
        secret = "local"
        type = "kind"
    }
  }

  clusters = {
    alpha = {
      argocd = false
      fluxcd = true
      branch = "main"
    }
    beta = {
      argocd = true
      fluxcd = false
      branch = "main"
    }
  }
}