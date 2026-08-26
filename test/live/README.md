# Live test harness

This `test/live/` directory is a real-Azure per-PR test harness, wired to
`.github/workflows/live-test.yml`. It applies the module against a throwaway
resource group + vnet/subnet, owned entirely by this harness.

## What it deploys

- A dedicated resource group + vnet/subnet (`test_dependencies.tf`), suffixed
  with `var.pr_number` so concurrently open PRs never collide.
- One `terraform-azurerm-caf-linux_virtual_machine_cluster` instance
  (`config/linux_virtual_machine_cluster.tfvars`): a two-node cluster (each
  node gets its own NIC via the module's own `linux_virtual_machine` child
  module) behind a shared availability set, using the `Dav6` VM size family -
  the sandbox subscription's default `Dsv5`/`Dasv5` family quota hits a hard
  Azure capacity restriction in `canadacentral`. No loadbalancer is wired in
  this fixture - that path is covered by the module's own
  `tests/loadbalancer.tftest.hcl` mock suite.

## Manual run

```bash
cd test/live
terraform init -backend-config="path=/tmp/live-test-manual.tfstate"
terraform plan -var-file=config/linux_virtual_machine_cluster.tfvars
terraform apply -var-file=config/linux_virtual_machine_cluster.tfvars
# ...
terraform destroy -var-file=config/linux_virtual_machine_cluster.tfvars
```

See the repo root's `.github/workflows/live-test.yml` for how CI wires two
checkouts (target branch baseline + PR branch) against the same state file.
