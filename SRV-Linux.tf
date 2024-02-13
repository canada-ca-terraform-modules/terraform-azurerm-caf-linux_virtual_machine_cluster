module "VMs" {
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-linux_virtual_machine?ref=v3.0.4"
  for_each = var.cluster_members

  env                                     = var.env
  serverType                              = var.serverType
  userDefinedString                       = var.userDefinedString
  postfix                                 = each.key
  resource_group                          = var.resource_group
  subnet                                  = var.subnet
  nic_ip_configuration                    = each.value.nic_ip_configuration
  public_ip                               = var.public_ip
  priority                                = var.priority
  license_type                            = var.license_type
  admin_username                          = var.admin_username
  admin_password                          = var.admin_password
  vm_size                                 = var.vm_size
  boot_diagnostic                         = var.boot_diagnostic
  storage_image_reference                 = var.storage_image_reference
  storage_os_disk                         = var.storage_os_disk
  os_managed_disk_type                    = var.os_managed_disk_type
  plan                                    = var.plan
  availability_set_id                     = azurerm_availability_set.availability_set.id
  custom_data                             = var.custom_data
  ultra_ssd_enabled                       = var.ultra_ssd_enabled
  zone                                    = var.zone
  data_disks                              = var.data_disks
  encryptDisks                            = var.encryptDisks
  dependancyAgent                         = var.dependancyAgent
  shutdownConfig                          = var.shutdownConfig
  use_nic_nsg                             = var.use_nic_nsg
  tags                                    = var.tags
  patch_assessment_mode    = var.cluster_patch_assessment_mode
  patch_mode               = var.cluster_patch_mode
}

resource "azurerm_network_interface_backend_address_pool_association" "LB_VMs" {
  for_each = var.lb != null ? var.cluster_members : {}

  network_interface_id    = module.VMs[each.key].nic.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.loadbalancer-lbbp[0].id
}
