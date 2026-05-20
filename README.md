# Kubernetes Cluster — Terraform Setup (OpenStack)

Infrastructure-as-Code project that provisions the base infrastructure for a Kubernetes cluster on UiA's OpenStack cloud (`kaun.uia.no`) using Terraform.

Part of the **IKT210 — Cloud Infrastructure** course at the University of Agder.

## What it provisions

- **Private network** (`vm_network`) with a `192.168.10.0/24` subnet, Google DNS, and a DHCP allocation pool
- **Router** connecting the private subnet to the external/provider network for internet access
- **3 Ubuntu Noble VMs** (`vm1`, `vm2`, `vm3`) with the `medium` flavor — intended as a 1 control-plane + 2 worker layout
- **Floating IPs** assigned to all three VMs so they are reachable from outside the tenant
- **SSH key pairs** (student + teacher) injected via cloud-init so both can SSH into `ubuntu@<vm>` without a password

## File structure

| File | Purpose |
|------|---------|
| `terraform.tf` | OpenStack provider config and authentication |
| `resources.tf` | Network, router, key pairs, VMs, and floating IPs |
| `.terraform.lock.hcl` | Provider version lock file |

## Requirements

- Terraform `>= 1.0`
- An OpenStack tenant on `kaun.uia.no` with valid credentials
- SSH key pair generated locally — update the `file(...)` paths in `resources.tf` to point to your own `.pub` keys

## Usage

```bash
terraform init
terraform plan
terraform apply
```

After apply, Terraform outputs the floating IPs. SSH in with:

```bash
ssh ubuntu@<floating-ip>
```

The VMs are then ready to be bootstrapped into a Kubernetes cluster (e.g. via `kubeadm`).

## Cleanup

```bash
terraform destroy
```

## Notes

- `terraform.tfstate` should normally **not** be committed (it may contain secrets and live infrastructure references). It is kept here only for coursework reference.
- Provider credentials are course-specific and tied to a tenant that is no longer active.
