data "dns_a_record_set" "duckdns" {
  host = local.host.dns_domain
}

