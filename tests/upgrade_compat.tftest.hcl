# tests/upgrade_compat.tftest.hcl
# Purpose: catch breaking resource changes before real infra plans.
# Note: baseline uses command = plan, not apply - this wrapper module chains
# many cross-resource ARM-ID references (LB -> backend pool/probe/rule,
# availability_set -> child VM module, NIC -> NSG association). A mock apply
# generates opaque non-ARM-format ids for every one of them simultaneously,
# and azurerm v5 strictly validates ARM ID format at apply time, so every
# such reference fails "parsing ...: the number of segments didn't match".
# Overriding every intermediate resource's id would be impractical here;
# matching the documented precedent for this module family, both runs use
# command = plan and compare the generated names/values directly instead of
# state-chaining through a real apply.
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

# Step 1: simulate the currently-deployed resource's plan (pre-upgrade inputs, no new args)
run "baseline_plan" {
  command = plan

  assert {
    condition     = azurerm_availability_set.availability_set.name == "ScScSRV-clustertest-as"
    error_message = "Baseline plan: unexpected availability set name"
  }
  assert {
    condition     = azurerm_lb.loadbalancer[0].name == "ScScSRV-clustertest-lb"
    error_message = "Baseline plan: unexpected loadbalancer name"
  }
}

# Step 2: plan the upgraded code (new optional args added) against that state
run "upgrade_plan_no_replacement" {
  command = plan

  variables {
    as_name             = null
    identity            = null
    secure_boot_enabled = null
    vtpm_enabled        = null
    user_data           = null
    public_ip_zones     = null
  }

  assert {
    condition     = azurerm_availability_set.availability_set.name == "ScScSRV-clustertest-as"
    error_message = "Availability set name must be unchanged after upgrade"
  }
  assert {
    condition     = azurerm_lb.loadbalancer[0].name == "ScScSRV-clustertest-lb"
    error_message = "Loadbalancer name must be unchanged after upgrade"
  }
  assert {
    condition     = azurerm_lb_rule.loadbalancer-lbr["tcp443"].floating_ip_enabled == true
    error_message = "floating_ip_enabled must still reflect the caller's enable_floating_ip value after the v5 rename"
  }
}
