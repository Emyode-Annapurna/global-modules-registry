locals {
  effective_name             = coalesce(var.name, lower(replace(var.display_name, " ", "-")))
  subscriptions_to_associate = var.enable_subscription_association ? var.subscription_ids : []
}
