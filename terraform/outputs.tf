output "ip_address" {
  value = local.host.ip_address
}

output "cluster" {
  value = var.cluster
}

output "type" {
  value = local.host.type
}

output "endpoint" {
  value = local.host.type == "kind" ? kind_cluster.kind[0].endpoint : null
}

# output secret_test {
#   value = nonsensitive(data.akeyless_static_secret.test.value)
# }