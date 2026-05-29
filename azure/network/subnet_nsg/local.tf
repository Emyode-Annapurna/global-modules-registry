locals {
  default_tags = {
    managed_by = "terraform"
    env        = var.env
  }

  merged_tags      = merge(local.default_tags, var.tags)
  subnets_with_nsg = { for name, subnet in var.subnets : name => subnet if try(subnet.create_nsg, false) }
}
