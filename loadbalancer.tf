/*
Documentation on the lb object required to define the loadbalancer

lb = {
  private_ip_address_allocation = "Static" # Optional. Default to Static
  private_ip_address = "10.10.10.10"
  sku = "Standard" # Optional. Default to Standard
  probes = {
    tcp443 = {
      port = 443 # Port to probe to detect health of vm
      interval_in_seconds = 5 # Optional. Default to 5
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
    },
    tcp80 = {
      protocol           = "TCP"
      frontend_port      = 80
      backend_port       = 80
      probe_name         = "tcp443"
      load_distribution  = "SourceIPProtocol"
      enable_floating_ip = true
    }
  }
}

*/

resource "azurerm_lb" "loadbalancer" {
  count = var.lb != null ? 1 : 0

  name                = "${local.name}-lb"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  frontend_ip_configuration {
    name                          = "${local.name}-lbfe"
    private_ip_address_allocation = lookup(var.lb, "private_ip_address_allocation", "Static")
    private_ip_address            = var.lb.private_ip_address
    subnet_id                     = var.subnet.id
  }
  sku = lookup(var.lb, "sku", "Standard")
}

resource "azurerm_lb_probe" "loadbalancer-lbhp" {
  for_each = try(var.lb.probes, {})

  # resource_group_name = var.resource_group.name
  loadbalancer_id     = azurerm_lb.loadbalancer[0].id
  name                = "${local.name}-${each.key}-lbhp"
  protocol            = lookup(each.value, "protocol", "Tcp")
  port                = each.value.port
  request_path        = lookup(each.value, "request_path", null)
  interval_in_seconds = lookup(each.value, "interval_in_seconds", 5)
  number_of_probes    = lookup(each.value, "number_of_probes", 2)
}

resource "azurerm_lb_backend_address_pool" "loadbalancer-lbbp" {
  count = var.lb != null ? 1 : 0

  loadbalancer_id = azurerm_lb.loadbalancer[0].id
  name            = "${local.name}-HA-lbbp"
}

resource "azurerm_lb_rule" "loadbalancer-lbr" {
  for_each = try(var.lb.rules, {})

  # resource_group_name            = var.resource_group.name
  loadbalancer_id                = azurerm_lb.loadbalancer[0].id
  name                           = "${local.name}-${each.key}-lbr"
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = "${local.name}-lbfe"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.loadbalancer-lbbp[0].id]
  probe_id                       = azurerm_lb_probe.loadbalancer-lbhp[each.value.probe_name].id
  load_distribution              = each.value.load_distribution
  enable_floating_ip             = each.value.enable_floating_ip
  idle_timeout_in_minutes        = try(each.value.idle_timeout_in_minutes, 4)
}
