locals {
  hosts = {
    local = {
        hostname = "localhost"
        ip_address = "127.0.0.1"
        dns_domain = "jklocal.duckdns.org"
        k8s_version = "1.31.0"
        ports = [80,443]
    }
  }
}