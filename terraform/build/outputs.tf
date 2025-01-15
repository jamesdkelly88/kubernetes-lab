output ip_address {
  value = local.hosts.local.ip_address
}

# output secret_test {
#   value = nonsensitive(data.akeyless_static_secret.test.value)
# }