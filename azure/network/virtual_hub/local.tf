locals {
  name_suffix_clean = try(trimspace(var.name_suffix), "")
  name              = local.name_suffix_clean != "" ? "${var.name}-${local.name_suffix_clean}" : var.name
  default_tags      = var.default_tags
  tags              = merge(local.default_tags, var.tags)
}
