terraform {
  required_providers {
    akeyless = {
      source  = "akeyless-community/akeyless"
      version = ">= 1.0.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.35.1"
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

provider "kubernetes" {
  config_path = pathexpand("~/.kube/${var.host}")
}