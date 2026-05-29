resource "azurerm_local_network_gateway" "this" {
  name                = trimspace(local.cfg.name)
  location            = trimspace(local.cfg.location)
  resource_group_name = trimspace(local.cfg.resource_group_name)
  gateway_address     = local.cfg.gateway_address
  address_space       = distinct(local.cfg.address_space)
  tags                = try(local.cfg.tags, {})

  dynamic "bgp_settings" {
    for_each = local.cfg.bgp_settings == null ? [] : [local.cfg.bgp_settings]

    content {
      asn                 = bgp_settings.value.asn
      bgp_peering_address = bgp_settings.value.bgp_peering_address
      peer_weight         = try(bgp_settings.value.peer_weight, null)
    }
  }
}
