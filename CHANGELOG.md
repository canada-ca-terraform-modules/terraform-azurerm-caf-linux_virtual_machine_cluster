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
- `admin_password` variable marked `sensitive = true` (was previously plaintext-visible in plan/apply output).
- `azurerm_lb_rule`'s `floating_ip_enabled`/`tcp_reset_enabled` now read via `try(..., null)` instead of a bare `each.value.*` reference, so a caller's `lb.rules.*` entry omitting either key no longer crashes the plan.
- Removed a hardcoded example password (`"ChangeMe123!"`) from `ESLZ/linux_virtual_machine_cluster.tfvars`, replaced with a comment directing callers to supply it via `TF_VAR_*` or a secrets store.
- `platform_fault_domain_count`/`platform_update_domain_count` retyped from `string` to `number` (defaults `2`/`3`) to match the provider schema and remove reliance on implicit string-to-number coercion.
- `doc.md`'s "Usage Example" referenced the old `linux_virtual_machine_ha` module path and the removed `nic_ip_configuration_1`/`_2` variables; replaced with a `cluster_members`-based example matching this module's actual current interface.
- `documentation.yml`'s docs-push step now guards with `if: github.event.pull_request.head.repo.full_name == github.repository`, since a fork PR's workflow token has no write access to push back to the fork branch.
- `tests/cluster.tftest.hcl`'s `data_managed_disk_type_wired` run set `data_disks` inside a `cluster_members` entry, but `data_disks` is a module-level (cluster-wide) variable, not a per-member key - the test's own assertion never actually exercised that path. Moved `data_disks` to the run's top-level `variables` block, matching the module's real (pre-existing, unchanged) design where all cluster members share one data-disk set.
- Removed the dead, already-commented-out `nic_ip_configuration_1`/`nic_ip_configuration_2` variable blocks from `variables.tf` (superseded by `cluster_members.*.nic_ip_configuration` since v1.0.0's "Make it support n vm").
- `documentation.yml`'s own docs-commit step was silently stripping `README.md`'s trailing newline on every PR push, requiring a manual fix-up commit each time. Split the render step (`git-push: "false"`) from a dedicated commit step that restores the trailing newline before committing; that step also needed `sudo chown -R` to reclaim workspace ownership left behind by the Docker-based `terraform-docs/gh-actions` action, and a staged-diff (`git diff --cached`) check instead of a working-tree diff check, since `.gitattributes`' `eol=lf` normalization made the latter appear non-empty even with nothing real to commit.

### Reviewed, no change needed

- `azurerm_lb_probe`'s `number_of_probes` argument is still valid in azurerm 5.0.1 (confirmed against the provider's own `v5.0.1`-tagged docs and this module's own `terraform validate`/`terraform test` runs against the real installed 5.0.1 provider schema) - a PR review comment claiming it was removed in v5 does not match the provider's actual schema.
- `tests/cluster.tftest.hcl`'s `per_instance_name_override` run asserts `module.VMs["m1"].name` - the child module exposes a top-level `output "name"` (`= azurerm_linux_virtual_machine.VM.name`), so this is the correct path, not `module.VMs["m1"].vm.name`.
- `ESLZ/linux_virtual_machine_cluster.tf` declaring its own `variable "tags"` mirrors the already-published sibling `terraform-azurerm-caf-linux_virtual_machine`'s own `ESLZ/linux_virtual_machine.tf` convention - not a regression introduced by this PR.

### Notes

- This module now adopts the `ESLZ/<resource>.tf` wrapper convention (`ESLZ/linux_virtual_machine_cluster.tf`). `release.yml` sources its version from that file's own `?ref=vX.Y.Z` - which currently points at this same `v2.0.0` release, since that's the version this PR introduces the file at. `documentation.yml` still uses terraform-docs `output-method: replace` (no `<!-- BEGIN_TF_DOCS -->` markers in `README.md`, matching the pre-existing `.terraform-docs.yml`/`generate-doc.md` manual workflow).
- Major version bump (not minor) because this upgrade adds the module's first `required_providers`/`required_version` floor - the first hard version constraint can break a consumer's existing Terraform/provider install even though no resource argument itself broke compatibility.
- No backward-compat breaks: every existing `cluster_members`/`lb` tfvars shape continues to produce the same plan.
