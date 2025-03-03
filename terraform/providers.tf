terraform {

  required_version = "~> 1.8"

  cloud {
    organization = "jdkhomelab-k8s"
    hostname     = "app.terraform.io"
  }

  required_providers {
    akeyless = {
      source  = "akeyless-community/akeyless"
      version = ">= 1.0.0"
    }

    dns = {
      source  = "hashicorp/dns"
      version = "3.4.2"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.0.0-pre1"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }

    kind = {
      source  = "tehcyx/kind"
      version = "0.8.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }

    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.6"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
  }
}

provider "akeyless" {
  api_gateway_address = "https://api.akeyless.io"

  api_key_login {
    access_id  = var.akeyless_id
    access_key = var.akeyless_key
  }
}

provider "dns" {}

provider "helm" {
  kubernetes = {
    host                   = local.host.type == "kind" ? kind_cluster.kind[0].endpoint : null
    client_certificate     = local.host.type == "kind" ? kind_cluster.kind[0].client_certificate : null
    client_key             = local.host.type == "kind" ? kind_cluster.kind[0].client_key : null
    cluster_ca_certificate = local.host.type == "kind" ? kind_cluster.kind[0].cluster_ca_certificate : null
  }
}

provider "http" {}

provider "kind" {}

provider "kubectl" {
  host                   = local.host.type == "kind" ? kind_cluster.kind[0].endpoint : null
  client_certificate     = local.host.type == "kind" ? kind_cluster.kind[0].client_certificate : null
  client_key             = local.host.type == "kind" ? kind_cluster.kind[0].client_key : null
  cluster_ca_certificate = local.host.type == "kind" ? kind_cluster.kind[0].cluster_ca_certificate : null
  load_config_file       = false
}


provider "kubernetes" {
  host                   = local.host.type == "kind" ? kind_cluster.kind[0].endpoint : null
  client_certificate     = local.host.type == "kind" ? kind_cluster.kind[0].client_certificate : null
  client_key             = local.host.type == "kind" ? kind_cluster.kind[0].client_key : null
  cluster_ca_certificate = local.host.type == "kind" ? kind_cluster.kind[0].cluster_ca_certificate : null
}

provider "kustomization" {
  kubeconfig_raw = local.host.type == "kind" ? kind_cluster.kind[0].kubeconfig : null
}

provider "null" {}

provider "time" {}