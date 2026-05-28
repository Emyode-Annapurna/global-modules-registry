variable "display_name" {
  description = "Display name of the management group"
  type        = string

  validation {
    condition     = length(trimspace(var.display_name)) > 0
    error_message = "display_name must not be empty or only whitespace."
  }
}

variable "name" {
  description = "ID of the management group. If null, a normalized name is generated from display_name"
  type        = string
  default     = null

  validation {
    condition     = var.name == null || can(regex("^[a-zA-Z0-9-._()]{1,90}$", var.name))
    error_message = "If provided, name must be 1-90 characters and contain only letters, numbers, dashes, dots, underscores, and parentheses."
  }
}

variable "parent_management_group_id" {
  description = "Optional parent management group ID (e.g. /providers/Microsoft.Management/managementGroups/contoso-root)"
  type        = string
  default     = ""

  validation {
    condition = (
      var.parent_management_group_id == "" ||
      can(regex("^/providers/Microsoft\\.Management/managementGroups/[a-zA-Z0-9-._()]{1,90}$", var.parent_management_group_id))
    )
    error_message = "parent_management_group_id must be empty or a valid management group resource ID, e.g. /providers/Microsoft.Management/managementGroups/mg-root."
  }
}

variable "tenant_id" {
  description = "Optional AAD tenant ID for cross-tenant MG scenarios"
  type        = string
  default     = ""

  validation {
    condition = (
      var.tenant_id == "" ||
      can(regex("^[0-9a-fA-F-]{36}$", var.tenant_id))
    )
    error_message = "tenant_id must be empty or a valid GUID."
  }
}

variable "subscription_ids" {
  description = "List of subscription IDs to attach to this management group"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for s in var.subscription_ids :
      can(regex("^[0-9a-fA-F-]{36}$", s))
    ])
    error_message = "All subscription_ids must be valid GUIDs."
  }
}

variable "attach_subscriptions_directly" {
  description = "If true, attach subscriptions using subscription_ids attribute on the management group resource"
  type        = bool
  default     = true
}

variable "enable_subscription_association" {
  description = "If true, create separate azurerm_management_group_subscription_association resources for each subscription"
  type        = bool
  default     = false

  validation {
    condition = !(
      var.attach_subscriptions_directly == true &&
      var.enable_subscription_association == true
    )
    error_message = "attach_subscriptions_directly and enable_subscription_association cannot both be true. Choose one strategy for attaching subscriptions."
  }
}
