terraform {

  required_version = "~> 1.8"

  cloud {
    organization = "jdkhomelab-k8s"
    hostname     = "app.terraform.io"
  }

  required_providers {
    bitwarden-secrets = {
      source  = "bitwarden/bitwarden-secrets"
      version = "0.5.4-pre"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    k8sconnect = {
      source  = "jmorris0x0/k8sconnect"
      version = "0.3.7"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.8.0"
    }
    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 5.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0-beta.2"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
    }
  }
}

provider "bitwarden-secrets" {
  api_url      = "https://api.bitwarden.com"
  identity_url = "https://identity.bitwarden.com"
}

provider "helm" {
  kubernetes = {
    host                   = data.talos_machine_configuration.this.cluster_endpoint
    client_certificate     = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
    cluster_ca_certificate = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
  }
}

provider "netbox" {
  server_url           = "https://netbox2.jk88.duckdns.org"
  allow_insecure_https = true
  request_timeout      = 120
  api_token            = data.bitwarden-secrets_secret.secrets["netbox"].value
}