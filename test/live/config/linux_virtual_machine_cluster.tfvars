# config/linux_virtual_machine_cluster.tfvars
# Minimal, valid fixture exercising the module's common path: a two-node
# cluster behind the module's own availability set, no loadbalancer (keeps
# the fixture minimal - the lb block is exercised by the module's own
# tests/loadbalancer.tftest.hcl mock suite).
#
# admin_password is a literal, obviously-fake placeholder - never a real
# secret.
#
# vm_size uses the Dav6 family: the sandbox subscription's default Dsv5/
# Dasv5 family quota hits a hard Azure capacity restriction (SkuNotAvailable)
# in canadacentral - Dav6 has dedicated quota provisioned for live-test use.
#
# storage_image_reference is set explicitly (not left to the module default)
# to a currently-available marketplace image.
linux_virtual_machine_cluster = {
  userDefinedString = "lvmclust"
  admin_username    = "azureadmin"
  admin_password    = "CHANGE-ME-P@ssw0rd1234!" # placeholder only - throwaway live-test VM, destroyed after use
  vm_size           = "Standard_D2as_v6"

  storage_image_reference = {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  cluster_members = {
    vm1 = {
      nic_ip_configuration = {
        private_ip_address            = [null]
        private_ip_address_allocation = ["Dynamic"]
      }
    }
    vm2 = {
      nic_ip_configuration = {
        private_ip_address            = [null]
        private_ip_address_allocation = ["Dynamic"]
      }
    }
  }
}
