# Changelog

All notable changes to this module are documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## v2.0.0 - 2026-08-13

### Added

- `providers.tf` pinning `azurerm ~> 5.0` (`required_version >= 1.9`) - none existed before this upgrade.
- Pass-through variables for the child `linux_virtual_machine` module's new azurerm 5.0.1-era arguments: `identity`, `secure_boot_enabled`, `vtpm_enabled`, `user_data`, `public_ip_zones`.
- Pattern 12 name overrides:
  - `as_name` (top-level) overrides the auto-generated availability set name.
  - Per cluster-member overrides read from each `cluster_members` entry: `vm_name`, `nic_name`, `nsg_name`, `os_disk_name`, `boot_diagnostic_storage_account_name` (passed through to the child VM module).
  - `lb.lb_name`, `lb.frontend_name`, `lb.backend_pool_name` override the auto-generated loadbalancer/frontend/backend-pool names; per-probe/per-rule `name` key overrides each probe/rule name.
- `.tflint.hcl` (`call_module_type = "local"`), `.gitattributes` (`eol=lf`), `.github/workflows/terraform-ci.yml`, `.github/workflows/documentation.yml`, `.github/workflows/release.yml`, `tests/*.tftest.hcl`.
- `sensitive = true` on the `VMs` and `availability_set` outputs (both expose full resource/module objects).
- `ESLZ/linux_virtual_machine_cluster.tf` + `ESLZ/linux_virtual_machine_cluster.tfvars` - the module block and commented example L2 callers copy into their blueprint (for_each over `linux_virtual_machine_clusters`, looking up `resource_groups`/`subnets` by key). `ESLZ/.tflint.hcl` disables `terraform_required_version`/`terraform_required_providers` for that directory only, since the file is copied verbatim into an L2 blueprint that already declares its own root `terraform {}` block. `doc.md` gained an "ESLZ Usage" section (carried into `README.md` by terraform-docs).

### Changed

- Bumped the child module `terraform-azurerm-caf-linux_virtual_machine` pin from `v3.0.15` to `v3.1.0` (already upgraded to `azurerm ~> 5.0`).
- `azurerm_lb_rule`: renamed resource arguments `enable_floating_ip` -> `floating_ip_enabled` and `enable_tcp_reset` -> `tcp_reset_enabled` (azurerm v5 rename). Caller-facing tfvars keys (`each.value.enable_floating_ip` / `each.value.enable_tcp_reset` inside `lb.rules`) are unchanged - zero caller-facing impact.
- `.gitignore` replaced with the standard template (previously scoped only to a stale `test/` subdirectory).

### Fixed

- `tags` default value had a duplicate `"exampleTag1"` map key (second entry silently overwrote the first); corrected to `"exampleTag2"`.
- `data_managed_disk_type` variable was declared but never wired to the child VM module (silently had no effect); now passed through as `data_managed_disk_type` on the `VMs` module block.

### Notes

- This module now adopts the `ESLZ/<resource>.tf` wrapper convention (`ESLZ/linux_virtual_machine_cluster.tf`). `release.yml` sources its version from that file's own `?ref=vX.Y.Z` - which currently points at this same `v2.0.0` release, since that's the version this PR introduces the file at. `documentation.yml` still uses terraform-docs `output-method: replace` (no `<!-- BEGIN_TF_DOCS -->` markers in `README.md`, matching the pre-existing `.terraform-docs.yml`/`generate-doc.md` manual workflow).
- Major version bump (not minor) because this upgrade adds the module's first `required_providers`/`required_version` floor - the first hard version constraint can break a consumer's existing Terraform/provider install even though no resource argument itself broke compatibility.
- No backward-compat breaks: every existing `cluster_members`/`lb` tfvars shape continues to produce the same plan.
