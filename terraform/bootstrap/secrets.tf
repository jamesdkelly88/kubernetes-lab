data "akeyless_static_secret" "akeyless_id" {
  path = "/k8s/config/credentials/${ var.host }/user"
}

data "akeyless_static_secret" "akeyless_key" {
  path = "/k8s/config/credentials/${ var.host }/password"
}

