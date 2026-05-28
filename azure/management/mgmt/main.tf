resource "azurerm_management_group" "this" {
  display_name               = var.display_name != "" ? var.display_name : local.effective_name
  name                       = local.effective_name != "" ? local.effective_name : null
  parent_management_group_id = var.parent_management_group_id != "" ? var.parent_management_group_id : null
  subscription_ids           = var.attach_subscriptions_directly ? var.subscription_ids : null
}

resource "azurerm_management_group_subscription_association" "this" {
  for_each            = toset(local.subscriptions_to_associate)
  management_group_id = azurerm_management_group.this.id
  subscription_id     = each.value
}
