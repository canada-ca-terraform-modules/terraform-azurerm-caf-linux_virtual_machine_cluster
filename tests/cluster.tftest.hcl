# tests/cluster.tftest.hcl
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
}

run "default_cluster_no_lb" {
  command = plan
  variables {
    cluster_members = {
      m1 = {
        nic_ip_configuration = {
          private_ip_address            = [null]
          private_ip_address_allocation = ["Dynamic"]
        }
      }
      m2 = {
        nic_ip_configuration = {
          private_ip_address            = [null]
          private_ip_address_allocation = ["Dynamic"]
        }
      }
    }
  }

  assert {
    condition     = length(module.VMs) == 2
    error_message = "One child VM module instance must be created per cluster member"
  }
  assert {
    condition     = length(azurerm_network_interface_backend_address_pool_association.LB_VMs) == 0
    error_message = "No NIC-LB association must be created when lb is null"
  }
}

run "cluster_with_lb" {
  command = plan
  variables {
    cluster_members = {
      m1 = {
        nic_ip_configuration = {
          private_ip_address            = [null]
          private_ip_address_allocation = ["Dynamic"]
        }
      }
      m2 = {
        nic_ip_configuration = {
          private_ip_address            = [null]
          private_ip_address_allocation = ["Dynamic"]
        }
      }
    }
    lb = {
      private_ip_address = "10.10.10.10"
      probes = {
        tcp443 = { port = 443 }
      }
      rules = {
        tcp443 = {
          protocol           = "Tcp"
          frontend_port      = 443
          backend_port       = 443
          probe_name         = "tcp443"
          load_distribution  = "SourceIPProtocol"
          enable_floating_ip = true
          enable_tcp_reset   = true
        }
      }
    }
  }

  assert {
    condition     = length(azurerm_network_interface_backend_address_pool_association.LB_VMs) == 2
    error_message = "One NIC-LB association must be created per cluster member when lb is configured"
  }
}

run "per_instance_name_override" {
  command = plan
  variables {
    cluster_members = {
      m1 = {
        vm_name  = "my-existing-vm"
        nic_name = "my-existing-nic"
        nic_ip_configuration = {
          private_ip_address            = [null]
          private_ip_address_allocation = ["Dynamic"]
        }
      }
    }
  }

  assert {
    condition     = module.VMs["m1"].name == "my-existing-vm"
    error_message = "vm_name override read from the cluster member must be passed through to the child module"
  }
}

run "data_managed_disk_type_wired" {
  command = plan
  variables {
    data_managed_disk_type = "Premium_LRS"
    cluster_members = {
      m1 = {
        data_disks = {
          data1 = { disk_size_gb = 50, lun = 0 }
        }
        nic_ip_configuration = {
          private_ip_address            = [null]
          private_ip_address_allocation = ["Dynamic"]
        }
      }
    }
  }

  assert {
    condition     = length(module.VMs) == 1
    error_message = "Plan must succeed with data_managed_disk_type wired through to the child module alongside data_disks"
  }
}

