resource "azurerm_availability_set" "availability_set" {
  name                         = var.as_name != null ? var.as_name : local.as-name
  location                     = var.resource_group.location
  resource_group_name          = var.resource_group.name
  platform_fault_domain_count  = var.platform_fault_domain_count
  platform_update_domain_count = var.platform_update_domain_count
  managed                      = var.platform_managed
  tags                         = var.tags
}
