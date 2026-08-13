# Terraform Basic Linux Virtual Machine HA

## Introduction

This module deploys an HA [virtual machine resource](https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/2019-03-01/virtualmachines) with an NSG, 1 NIC and a simple OS Disk.

## Security Controls

The following security controls can be met through configuration of this template:

* AC-1, AC-10, AC-11, AC-11(1), AC-12, AC-14, AC-16, AC-17, AC-18, AC-18(4), AC-2 , AC-2(5), AC-20(1) , AC-20(3), AC-20(4), AC-24(1), AC-24(11), AC-3, AC-3 , AC-3(1), AC-3(3), AC-3(9), AC-4, AC-4(14), AC-6, AC-6, AC-6(1), AC-6(10), AC-6(11), AC-7, AC-8, AC-8, AC-9, AC-9(1), AI-16, AU-2, AU-3, AU-3(1), AU-3(2), AU-4, AU-5, AU-5(3), AU-8(1), AU-9, CM-10, CM-11(2), CM-2(2), CM-2(4), CM-3, CM-3(1), CM-3(6), CM-5(1), CM-6, CM-6, CM-7, CM-7, IA-1, IA-2, IA-3, IA-4(1), IA-4(4), IA-5, IA-5, IA-5(1), IA-5(13), IA-5(1c), IA-5(6), IA-5(7), IA-9, SC-10, SC-13, SC-15, SC-18(4), SC-2, SC-2, SC-23, SC-28, SC-30(5), SC-5, SC-7, SC-7(10), SC-7(16), SC-7(8), SC-8, SC-8(1), SC-8(4), SI-14, SI-2(1), SI-3

## Dependancies

Hard:

* Resource Groups
* Keyvault
* VNET-Subnet

Optional (depending on options configured):

* log analytics workspace

## Usage Example

```hcl
module "linux_VMs_cluster" {
  source   = "./modules/terraform-azurerm-caf-linux_virtual_machine_cluster"
  for_each = local.deployListLinuxCluster

  env               = var.env
  serverType        = each.value.serverType
  userDefinedString = each.value.userDefinedString
  resource_group    = local.resource_groups_L2[each.value.resource_group]
  subnet            = local.subnets[each.value.subnet]

  # One entry per VM in the cluster - each member gets its own NIC IP configuration
  # and may optionally override its own auto-generated resource names (Pattern 12).
  cluster_members = {
    node1 = {
      nic_ip_configuration = {
        private_ip_address            = [lookup(each.value, "private_ip_address_node1", "Dynamic") == "Dynamic" ? null : each.value.private_ip_address_node1]
        private_ip_address_allocation = [lookup(each.value, "private_ip_address_node1", "Dynamic") == "Dynamic" ? "Dynamic" : "Static"]
      }
    }
    node2 = {
      nic_ip_configuration = {
        private_ip_address            = [lookup(each.value, "private_ip_address_node2", "Dynamic") == "Dynamic" ? null : each.value.private_ip_address_node2]
        private_ip_address_allocation = [lookup(each.value, "private_ip_address_node2", "Dynamic") == "Dynamic" ? "Dynamic" : "Static"]
      }
    }
  }

  public_ip               = lookup(each.value, "public_ip", false)
  priority                = lookup(each.value, "priority", "Regular")
  license_type            = lookup(each.value, "license_type", null)
  admin_username          = lookup(each.value, "admin_username", "azureadmin")
  admin_password          = each.value.admin_password
  vm_size                 = each.value.vm_size
  storage_image_reference = lookup(each.value, "storage_image_reference", local.linux_storage_image_reference_ha)
  storage_os_disk         = lookup(each.value, "storage_os_disk", null)
  os_managed_disk_type    = lookup(each.value, "os_managed_disk_type", null)
  data_managed_disk_type  = lookup(each.value, "data_managed_disk_type", null)
  plan                    = lookup(each.value, "plan", null)
  custom_data             = lookup(each.value, "custom_data", false) != false ? base64encode(file(each.value.custom_data)) : null
  ultra_ssd_enabled       = lookup(each.value, "ultra_ssd_enabled", false)
  zone                    = lookup(each.value, "zone", null)
  data_disks              = lookup(each.value, "data_disks", {})
  encryptDisks = lookup(each.value, "encryptDisks", false) != false ? {
    KeyVaultResourceId = local.Project-kv.id
    KeyVaultURL        = local.Project-kv.vault_uri
  } : null
  dependancyAgent = lookup(each.value, "dependancyAgent", false)
  shutdownConfig  = lookup(each.value, "shutdownConfig", null)
  lb              = lookup(each.value, "lb", null)
  tags            = lookup(each.value, "tags", null) == null ? var.tags : merge(var.tags, each.value.tags)
}
```

## ESLZ Usage

Copy [ESLZ/linux_virtual_machine_cluster.tf](./ESLZ/linux_virtual_machine_cluster.tf) into an ESLZ L2 blueprint and populate `linux_virtual_machine_cluster.tfvars` - see [ESLZ/linux_virtual_machine_cluster.tfvars](./ESLZ/linux_virtual_machine_cluster.tfvars) for a full example, including every supported optional key.

### ESLZ module block (`ESLZ/linux_virtual_machine_cluster.tf`)

```hcl
module "linux_virtual_machine_cluster" {
  source          = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-linux_virtual_machine_cluster?ref=v2.0.0"
  for_each        = var.linux_virtual_machine_clusters
  resource_groups = var.resource_groups
  subnets         = var.subnets
  tags            = var.tags
  # ... see ESLZ/linux_virtual_machine_cluster.tf for every argument wired through
}
```

### ESLZ tfvars pattern (`ESLZ/linux_virtual_machine_cluster.tfvars`)

```hcl
linux_virtual_machine_clusters = {
  SRV-APPHA1 = {
    env                = "Prod"
    userDefinedString  = "apphacluster"
    resource_group_key = "Project"
    subnet_key         = "app"
    admin_username     = "adminuser"
    vm_size            = "Standard_D2s_v5"

    cluster_members = {
      node1 = { nic_ip_configuration = { private_ip_address = [null], private_ip_address_allocation = ["Dynamic"] } }
      node2 = { nic_ip_configuration = { private_ip_address = [null], private_ip_address_allocation = ["Dynamic"] } }
    }
  }
}
```

