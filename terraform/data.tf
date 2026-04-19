data "netbox_virtual_machines" "lookup" {
  name_regex = local.name
}

data "netbox_interfaces" "lookup" {
  filter {
    name  = "vm_id"
    value = local.vm.vm_id
  }
}

data "bitwarden-secrets_secret" "secrets" {
  for_each = tomap({
    netbox = "18b5879e-acf6-4c4b-8e12-b31c007cac94"
  })
  id = each.value
}