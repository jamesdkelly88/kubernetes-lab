terraform {

  cloud {
    organization = "jdkhomelab-k8s"
    hostname = "app.terraform.io"
  }

  required_providers {
    akeyless = {
      source  = "akeyless-community/akeyless"
      version = ">= 1.0.0"
    }

    kind = {
      source = "tehcyx/kind"
      version = "0.7.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.35.1"
    }

    time = {
      source = "hashicorp/time"
      version = "0.12.1"
    }
  }
}

provider "akeyless" {
  api_gateway_address = "https://api.akeyless.io"

  api_key_login {
    access_id = var.akeyless_id
    access_key = var.akeyless_key
  }
}

provider "kind" {}

provider "kubernetes" {
  host                   = local.hosts[var.host].type == "kind" ? kind_cluster.kind[0].endpoint : null
  client_certificate     = local.hosts[var.host].type == "kind" ? kind_cluster.kind[0].client_certificate : null
  client_key             = local.hosts[var.host].type == "kind" ? kind_cluster.kind[0].client_key : null
  cluster_ca_certificate = local.hosts[var.host].type == "kind" ? kind_cluster.kind[0].cluster_ca_certificate : null
}

provider "time" {}