terraform {
  # Touch to satisfy live-test.yml's pull_request path filter (test/live/** or *.tf) for this PR.
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 5.0"
    }
  }

  # Empty on purpose: the state file path is supplied at `terraform init`
  # time via `-backend-config="path=..."` (partial configuration), so the
  # target-branch checkout and the PR-branch checkout can point at the same
  # external state file without either owning its own local state.
  backend "local" {}
}

provider "azurerm" {
  storage_use_azuread             = true
  resource_provider_registrations = "legacy"
  features {}
}

module "linux_virtual_machine_cluster" {
  # PR code and baseline code are two on-disk checkouts of this same repo,
  # not two resolved git refs - no pinned ?ref, no version toggle here.
  source = "../../"

  env                     = var.env
  userDefinedString       = try(var.linux_virtual_machine_cluster.userDefinedString, "livetest")
  resource_group          = local.resource_group # from test_dependencies.tf
  subnet                  = local.subnet         # from test_dependencies.tf
  cluster_members         = var.linux_virtual_machine_cluster.cluster_members
  admin_username          = var.linux_virtual_machine_cluster.admin_username
  admin_password          = try(var.linux_virtual_machine_cluster.admin_password, null)
  vm_size                 = var.linux_virtual_machine_cluster.vm_size
  storage_image_reference = try(var.linux_virtual_machine_cluster.storage_image_reference, null)
  tags                    = var.tags
}
