# ESLZ/linux_virtual_machine_cluster.tfvars
# Example tfvars for the ESLZ/linux_virtual_machine_cluster.tf module block.
# Rules: existing entries unchanged; new args go below, commented out with explanation.

linux_virtual_machine_clusters = {
  # --- EXISTING ENTRY (minimal, backward compatible) ---
  SRV-APPHA1 = {
    env                = "Prod"
    userDefinedString  = "apphacluster"
    resource_group_key = "Project"
    subnet_key         = "app"
    admin_username     = "adminuser"
    admin_password     = "ChangeMe123!"
    vm_size            = "Standard_D2s_v5"

    cluster_members = {
      node1 = {
        nic_ip_configuration = {
          private_ip_address            = [null]
          private_ip_address_allocation = ["Dynamic"]
        }
      }
      node2 = {
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

  # --- NEW ARGUMENT EXAMPLES (commented out) ---
  # SRV-APPHA2 = {
  #   env                = "Prod"
  #   userDefinedString  = "apphacluster2"
  #   resource_group_key = "Project"
  #   subnet_key         = "app"
  #   admin_username     = "adminuser"
  #   vm_size            = "Standard_D2s_v5"
  #
  #   cluster_members = {
  #     node1 = {
  #       nic_ip_configuration = {
  #         private_ip_address            = [null]
  #         private_ip_address_allocation = ["Dynamic"]
  #       }
  #
  #       # Pattern 12: pin an already-deployed resource name that diverges
  #       # from the module's naming formula (avoids destroy/recreate)
  #       # vm_name  = "existing-prod-vm-node1"
  #       # nic_name = "existing-prod-nic-node1"
  #     }
  #   }
  #
  #   # New: system-assigned managed identity
  #   identity = {
  #     type = "SystemAssigned"
  #   }
  #
  #   # New: Trusted Launch (secure boot + vTPM)
  #   secure_boot_enabled = true
  #   vtpm_enabled        = true
  #
  #   # New: cloud-init user data (base64-encoded)
  #   user_data = "IyEvYmluL3NoCmVjaG8gaGVsbG8="
  #
  #   # New: pin availability zones for the public IP
  #   public_ip       = true
  #   public_ip_zones = ["1", "2"]
  #
  #   # Pattern 12: pin an already-deployed availability set name
  #   # as_name = "existing-prod-as"
  #
  #   # Pattern 12: pin already-deployed loadbalancer resource names
  #   lb = {
  #     # lb_name           = "existing-prod-lb"
  #     # frontend_name     = "existing-prod-lb-fe"
  #     # backend_pool_name = "existing-prod-lb-bp"
  #     private_ip_address = "10.10.20.10"
  #     probes = {
  #       tcp443 = {
  #         # name = "existing-prod-probe"
  #         port = 443
  #       }
  #     }
  #     rules = {
  #       tcp443 = {
  #         # name                = "existing-prod-rule"
  #         protocol            = "Tcp"
  #         frontend_port       = 443
  #         backend_port        = 443
  #         probe_name          = "tcp443"
  #         load_distribution   = "SourceIPProtocol"
  #         enable_floating_ip  = true
  #         enable_tcp_reset    = true
  #       }
  #     }
  #   }
  # }
}
