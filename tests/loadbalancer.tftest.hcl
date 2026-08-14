# tests/loadbalancer.tftest.hcl
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

run "no_lb" {
  command = plan

  assert {
    condition     = length(azurerm_lb.loadbalancer) == 0
    error_message = "No loadbalancer must be created when lb is null"
  }
}

run "default_values" {
  command = plan
  variables {
    lb = {
      private_ip_address = "10.10.10.10"
      probes = {
        tcp443 = {
          port = 443
        }
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
    condition     = azurerm_lb.loadbalancer[0].name == "ScScSRV-clustertest-lb"
    error_message = "LB name must follow {name}-lb convention"
  }
  assert {
    condition     = azurerm_lb.loadbalancer[0].frontend_ip_configuration[0].name == "ScScSRV-clustertest-lbfe"
    error_message = "Frontend name must follow {name}-lbfe convention"
  }
  assert {
    condition     = azurerm_lb_backend_address_pool.loadbalancer-lbbp[0].name == "ScScSRV-clustertest-HA-lbbp"
    error_message = "Backend pool name must follow {name}-HA-lbbp convention"
  }
  assert {
    condition     = azurerm_lb_probe.loadbalancer-lbhp["tcp443"].name == "ScScSRV-clustertest-tcp443-lbhp"
    error_message = "Probe name must follow {name}-{key}-lbhp convention"
  }
  assert {
    condition     = azurerm_lb_rule.loadbalancer-lbr["tcp443"].name == "ScScSRV-clustertest-tcp443-lbr"
    error_message = "Rule name must follow {name}-{key}-lbr convention"
  }
  # azurerm v5 rename: resource arguments are floating_ip_enabled/tcp_reset_enabled,
  # while the caller-facing tfvars keys (enable_floating_ip/enable_tcp_reset) are unchanged
  assert {
    condition     = azurerm_lb_rule.loadbalancer-lbr["tcp443"].floating_ip_enabled == true
    error_message = "floating_ip_enabled must be wired from caller's enable_floating_ip key"
  }
  assert {
    condition     = azurerm_lb_rule.loadbalancer-lbr["tcp443"].tcp_reset_enabled == true
    error_message = "tcp_reset_enabled must be wired from caller's enable_tcp_reset key"
  }
}

run "name_overrides" {
  command = plan
  variables {
    lb = {
      lb_name            = "existing-lb"
      frontend_name      = "existing-lb-fe"
      backend_pool_name  = "existing-lb-bp"
      private_ip_address = "10.10.10.10"
      probes = {
        tcp443 = {
          name = "existing-probe"
          port = 443
        }
      }
      rules = {
        tcp443 = {
          name               = "existing-rule"
          protocol           = "Tcp"
          frontend_port      = 443
          backend_port       = 443
          probe_name         = "tcp443"
          load_distribution  = "SourceIPProtocol"
          enable_floating_ip = false
          enable_tcp_reset   = false
        }
      }
    }
  }

  assert {
    condition     = azurerm_lb.loadbalancer[0].name == "existing-lb"
    error_message = "lb_name override must be applied"
  }
  assert {
    condition     = azurerm_lb.loadbalancer[0].frontend_ip_configuration[0].name == "existing-lb-fe"
    error_message = "frontend_name override must be applied"
  }
  assert {
    condition     = azurerm_lb_backend_address_pool.loadbalancer-lbbp[0].name == "existing-lb-bp"
    error_message = "backend_pool_name override must be applied"
  }
  assert {
    condition     = azurerm_lb_probe.loadbalancer-lbhp["tcp443"].name == "existing-probe"
    error_message = "probe name override must be applied"
  }
  assert {
    condition     = azurerm_lb_rule.loadbalancer-lbr["tcp443"].name == "existing-rule"
    error_message = "rule name override must be applied"
  }
}
