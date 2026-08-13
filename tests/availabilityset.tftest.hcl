# tests/availabilityset.tftest.hcl
mock_provider "azurerm" {}

variables {
  env               = "ScSc"
  serverType        = "SRV"
  userDefinedString = "clustertest"
  admin_username    = "azureadmin"
  vm_size           = "Standard_F4"
  resource_group = {
    id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
    name     = "rg-test"
    location = "canadacentral"
  }
  subnet = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
  }
  cluster_members = {
    m1 = {
      nic_ip_configuration = {
        private_ip_address            = [null]
        private_ip_address_allocation = ["Dynamic"]
      }
    }
  }
}

run "naming_convention" {
  command = plan

  assert {
    condition     = azurerm_availability_set.availability_set.name == "ScScSRV-clustertest-as"
    error_message = "Availability set name must follow {env4}{serverType3}-{userDefinedString}-as convention"
  }
}

run "default_values" {
  command = plan

  assert {
    condition     = azurerm_availability_set.availability_set.managed == true
    error_message = "platform_managed default must be true"
  }
  assert {
    condition     = azurerm_availability_set.availability_set.platform_fault_domain_count == 2
    error_message = "platform_fault_domain_count default must be 2"
  }
  assert {
    condition     = azurerm_availability_set.availability_set.platform_update_domain_count == 3
    error_message = "platform_update_domain_count default must be 3"
  }
}

run "as_name_override" {
  command = plan
  variables {
    as_name = "existing-prod-availability-set"
  }

  assert {
    condition     = azurerm_availability_set.availability_set.name == "existing-prod-availability-set"
    error_message = "as_name override must take priority over the generated name"
  }
}
