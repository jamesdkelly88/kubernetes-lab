data "netbox_virtual_machines" "lookup" {
  name_regex = local.name
}

data "bitwarden-secrets_secret" "secrets" {
  for_each = tomap({
    netbox = "18b5879e-acf6-4c4b-8e12-b31c007cac94"
    bws    = "e15b3302-795f-4ccf-9751-b43a011cbe2c"
  })
  id = each.value
}