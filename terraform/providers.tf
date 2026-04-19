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
    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 5.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0-beta.2"
    }
  }
}

provider "bitwarden-secrets" {
  api_url      = "https://api.bitwarden.com"
  identity_url = "https://identity.bitwarden.com"
}

provider "netbox" {
  server_url           = "https://netbox2.jk88.duckdns.org"
  allow_insecure_https = true
  request_timeout      = 120
  api_token            = data.bitwarden-secrets_secret.secrets["netbox"].value
}