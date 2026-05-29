resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = lookup(each.value, "service_endpoints", [])
  dynamic "delegation" {
    for_each = try(each.value.enable_delegation, false) ? [1] : []

    content {
      name = "${each.key}-delegation"

      service_delegation {
        name = each.value.delegation_service
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
        ]
      }
    }
  }
}

resource "azurerm_network_security_group" "this" {
  for_each            = local.subnets_with_nsg
  name                = coalesce(try(each.value.nsg_name, null), lower(format("%s-%s-nsg", var.env, each.key)))
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.merged_tags

  dynamic "security_rule" {
    for_each = coalesce(each.value.nsg_rules, [])
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefixes    = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = local.subnets_with_nsg
  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}
