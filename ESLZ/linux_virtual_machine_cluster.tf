# ESLZ/linux_virtual_machine_cluster.tf
# Declares the variables consumed by the module block so L2 callers can wire
# their own var.* values in, and the module block itself. Copy this file into
# an ESLZ L2 blueprint and populate linux_virtual_machine_cluster.tfvars.
#
# Provider requirement for this module: azurerm ~> 5.0, required_version >= 1.9
# (see providers.tf in the module root). Do NOT add a `terraform {}` block to
# this file - it is copied verbatim into an L2 blueprint that already declares
# its own root `terraform {}` block, and a second one here would collide with
# it (duplicate required_providers/required_version block error).

variable "linux_virtual_machine_clusters" {
  description = "Map of Linux VM cluster configuration objects. See ESLZ/linux_virtual_machine_cluster.tfvars for examples of every supported key."
  type        = any
  default     = {}
}

variable "resource_groups" {
  description = "Map of resource group objects (key referenced by each cluster's resource_group_key)"
  type        = any
  default     = {}
}

variable "subnets" {
  description = "Map of subnet objects (key referenced by each cluster's subnet_key)"
  type        = any
  default     = {}
}

variable "tags" {
  description = "Tags to apply to all resources created by this module block"
  type        = map(string)
  default     = {}
}

module "linux_virtual_machine_cluster" {
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-linux_virtual_machine_cluster?ref=v2.0.0"
  for_each = var.linux_virtual_machine_clusters

  # Naming
  env               = each.value.env
  serverType        = try(each.value.serverType, "SRV")
  userDefinedString = each.value.userDefinedString

  # Placement
  resource_group = var.resource_groups[each.value.resource_group_key]
  subnet         = var.subnets[each.value.subnet_key]

  # Cluster members - map of { <member_key> = { nic_ip_configuration = {...}, ... } }
  cluster_members = each.value.cluster_members

  # Identity / auth
  admin_username = each.value.admin_username
  admin_password = try(each.value.admin_password, null)

  # Compute / image
  vm_size                 = each.value.vm_size
  storage_image_reference = try(each.value.storage_image_reference, null)
  plan                    = try(each.value.plan, null)
  zone                    = try(each.value.zone, null)
  priority                = try(each.value.priority, "Regular")
  license_type            = try(each.value.license_type, null)
  custom_data             = try(each.value.custom_data, null)
  user_data               = try(each.value.user_data, null)
  identity                = try(each.value.identity, null)

  # Trusted Launch / host security
  secure_boot_enabled = try(each.value.secure_boot_enabled, null)
  vtpm_enabled        = try(each.value.vtpm_enabled, null)
  ultra_ssd_enabled   = try(each.value.ultra_ssd_enabled, false)

  # Patching
  cluster_patch_mode            = try(each.value.cluster_patch_mode, null)
  cluster_patch_assessment_mode = try(each.value.cluster_patch_assessment_mode, null)

  # Disks
  storage_os_disk        = try(each.value.storage_os_disk, null)
  os_managed_disk_type   = try(each.value.os_managed_disk_type, "Standard_LRS")
  data_managed_disk_type = try(each.value.data_managed_disk_type, "Standard_LRS")
  data_disks             = try(each.value.data_disks, {})

  # Networking
  use_nic_nsg     = try(each.value.use_nic_nsg, true)
  public_ip       = try(each.value.public_ip, false)
  public_ip_zones = try(each.value.public_ip_zones, null)

  # Availability set
  platform_fault_domain_count  = try(each.value.platform_fault_domain_count, "2")
  platform_update_domain_count = try(each.value.platform_update_domain_count, "3")
  platform_managed             = try(each.value.platform_managed, true)
  as_name                      = try(each.value.as_name, null)

  # Load balancer (optional - omit entirely for no HA loadbalancer)
  lb = try(each.value.lb, null)

  # Boot diagnostics
  boot_diagnostic = try(each.value.boot_diagnostic, false)

  # Extensions / lifecycle options
  dependancyAgent = try(each.value.dependancyAgent, false)
  encryptDisks    = try(each.value.encryptDisks, null)
  shutdownConfig  = try(each.value.shutdownConfig, null)

  # Tags
  tags = merge(var.tags, try(each.value.tags, {}))
}
