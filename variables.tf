variable "tags" {
  description = "Tags that will be associated to VM resources"
  type        = map(string)
  default = {
    "exampleTag1" = "SomeValue1"
    "exampleTag1" = "SomeValue2"
  }
}
variable "env" {
  description = "4 chars defining the environment name prefix for the VM. Example: ScSc"
  type        = string
}
variable "serverType" {
  description = "3 chars server type code for the VM."
  type        = string
  default     = "SRV"
}
variable "userDefinedString" {
  description = "User defined portion of the server name. Up to 8 chars minus the postfix lenght"
  type        = string
}
variable "resource_group" {
  description = "Resourcegroup object that will contain the VM resources"
  type        = any
}
variable "subnet" {
  description = "subnet object to which the VM NIC will connect to"
  type        = any
}
# variable "nic_ip_configuration_1" {
#   description = "Defines how a private IP address is assigned. Options are Static or Dynamic. In case of Static also specifiy the desired privat IP address. See variable.tf file for example"
#   type = object({
#     private_ip_address            = list(string)
#     private_ip_address_allocation = list(string)
#   })
#   default = {
#     private_ip_address            = [null]
#     private_ip_address_allocation = ["Dynamic"]
#   }
#   /*
#     Example variable for a NIC with 2 staticly assigned IP and one dynamic:
#     ```hcl
#     nic_ip_configuration = {
#       private_ip_address            = ["10.20.30.42","10.20.40.43",null]
#       private_ip_address_allocation = ["Static","Static","Dynamic"]
#     }
#     ```
#   */
# }
# variable "nic_ip_configuration_2" {
#   description = "Defines how a private IP address is assigned. Options are Static or Dynamic. In case of Static also specifiy the desired privat IP address. See variable.tf file for example"
#   type = object({
#     private_ip_address            = list(string)
#     private_ip_address_allocation = list(string)
#   })
#   default = {
#     private_ip_address            = [null]
#     private_ip_address_allocation = ["Dynamic"]
#   }
#   /*
#     Example variable for a NIC with 2 staticly assigned IP and one dynamic:
#     ```hcl
#     nic_ip_configuration = {
#       private_ip_address            = ["10.20.30.42","10.20.40.43",null]
#       private_ip_address_allocation = ["Static","Static","Dynamic"]
#     }
#     ```
#   */
# }
variable "cluster_members" {
  description = "Config of each cluster member"
  type = any
}
variable "public_ip" {
  description = "Should the VM be assigned public IP(s). True or false."
  type        = bool
  default     = false
}
variable "priority" {
  description = "Specifies the priority of this Virtual Machine. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created."
  type        = string
  default     = "Regular"
}
variable "license_type" {
  description = " (Optional) Specifies the BYOL Type for this Virtual Machine. Possible values are RHEL_BYOS and SLES_BYOS."
  type        = string
  default     = null
}
variable "admin_username" {
  description = "Name of the VM admin account"
  type        = string
}

variable "admin_password" {
  description = "Password of the VM admin account"
  type        = string
  default     = null
}
variable "vm_size" {
  description = "Specifies the size of the Virtual Machine. Eg: Standard_F4"
  type        = string
}
variable "storage_image_reference" {
  description = "This block provisions the Virtual Machine from one of two sources: an Azure Platform Image (e.g. Ubuntu/Windows Server) or a Custom Image. Refer to https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html for more details."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "RedHat",
    offer     = "RHEL",
    sku       = "7.4",
    version   = "latest"
  }
}
variable "storage_os_disk" {
  description = "This block describe the parameters for the OS disk. Refer to https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine#os_disk for more details."
  type = object({
    caching       = string
    create_option = string
    disk_size_gb  = number
  })
  default = {
    caching       = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb  = null
  }
}
variable "data_managed_disk_type" {
  description = "Specifies the type of Data Managed Disk which should be created. Possible values are Standard_LRS or Premium_LRS."
  type        = string
  default     = "Standard_LRS"
}
variable "os_managed_disk_type" {
  description = "Specifies the type of OS Managed Disk which should be created. Possible values are Standard_LRS or Premium_LRS."
  type        = string
  default     = "Standard_LRS"
}
variable "plan" {
  description = "An optional plan block"
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  default = null
}
variable "custom_data" {
  description = "Specifies custom data to supply to the machine. On Linux-based systems, this can be used as a cloud-init script. On other systems, this will be copied as a file on disk. Internally, Terraform will base64 encode this value before sending it to the API. The maximum length of the binary array is 65535 bytes."
  type        = string
  default     = null
}
variable "ultra_ssd_enabled" {
  description = "Should the capacity to enable Data Disks of the UltraSSD_LRS storage account type be supported on this Virtual Machine?"
  type        = bool
  default     = false
}
variable "zone" {
  description = "The Zone in which this Virtual Machine should be created. Changing this forces a new resource to be created."
  type        = any
  default     = null
}
variable "data_disks" {
  description = "Map of object of disk sizes in gigabytes and lun number for each desired data disks. See variable.tf file for example"
  type        = any
  default     = {}
  /*
    Example: 
    data_disks = {
      "data1" = {
        disk_size_gb = 50
        lun          = 0
      },
      "data2" = {
        disk_size_gb = 50
        lun          = 1
      }
    }
  */
}
variable "encryptDisks" {
  description = "Should the VM disks be encrypted. See option-30-AzureDiskEncryption.tf file for example"
  type = object({
    KeyVaultResourceId = string
    KeyVaultURL        = string
  })
  default = null
}
variable "dependancyAgent" {
  description = "Should the VM be include the dependancy agent"
  default     = false
  type        = bool
}
variable "shutdownConfig" {
  description = "Should the VM shutdown at the time specified. See option-30-autoshutdown.tf file for example"
  type = object({
    autoShutdownStatus             = string
    autoShutdownTime               = string
    autoShutdownTimeZone           = string
    autoShutdownNotificationStatus = string
  })
  default = null
}

variable "platform_fault_domain_count" {
  description = "(Optional) Specifies the number of update domains that are used. Defaults to 5. Changing this forces a new resource to be created."
  type = string
  default = "2"
}

variable "platform_update_domain_count" {
  description = "(Optional) Specifies the number of fault domains that are used. Defaults to 3. Changing this forces a new resource to be created."
  type = string
  default = "3"
}

variable "platform_managed" {
  description = "(Optional) Specifies whether the availability set is managed or not. Possible values are true (to specify aligned) or false (to specify classic)."
  type = bool
  default = true
}
  
variable "boot_diagnostic" {
  description = "(Optional)"
  type = bool
  default = false
}

variable "lb" {
  description = "(Optional) Loadbalancer configuration for the HA VMs."
  type        = any
  default     = null
}

variable "cluster_patch_assessment_mode" {
  description = "(Optional) Specifies the mode of VM Guest Patching for the Virtual Machine. Possible values are AutomaticByPlatform or ImageDefault. Defaults to ImageDefault."
  type        = string
  default     = null
}

variable "cluster_patch_mode" {
  description = "(Optional) Specifies the mode of in-guest patching to this Windows Virtual Machine. Possible values are Manual, AutomaticByOS and AutomaticByPlatform. Defaults to AutomaticByOS."
  type        = string
  default     = null
}