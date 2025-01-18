output ip_address {
  value = local.hosts.local.ip_address
}

output cluster {
  value = var.cluster
}

output type {
  value = local.hosts[var.host].type
}

output endpoint {
  value = local.hosts[var.host].type == "kind" ? kind_cluster.kind[0].endpoint : null
}

# output secret_test {
#   value = nonsensitive(data.akeyless_static_secret.test.value)
# }