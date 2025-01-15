terraform {
  required_providers {
    akeyless = {
      source  = "akeyless-community/akeyless"
      version = ">= 1.0.0"
    }

    kind = {
      source = "tehcyx/kind"
      version = "0.7.0"
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