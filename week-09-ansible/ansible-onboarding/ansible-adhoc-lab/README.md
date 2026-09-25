# Ansible Ad-Hoc Lab

**Owner:** Oluwagbade Odimayo

**Cloud:** AWS (eu-west-2, London), four-VM option

## What this lab does

Terraform provisions four Ubuntu 24.04 VMs on AWS, one per role, and Ansible manages them with
ad-hoc commands from the controller built in the parent `ansible-onboarding` workspace.

| Host | Role | Inbound access |
|---|---|---|
| web1 | web | SSH from controller IP only, HTTP 80 from anywhere |
| web2 | web | SSH from controller IP only, HTTP 80 from anywhere |
| app1 | app | SSH from controller IP only |
| db1 | db | SSH from controller IP only |

## Layout

| Path | Purpose |
|---|---|
| `terraform/providers.tf` | Terraform and AWS provider versions, default tags |
| `terraform/variables.tf` | Region, instance type, controller CIDR, key path, server map with roles |
| `terraform/main.tf` | VPC, public subnet, security groups, key pair, four instances via `for_each` |
| `terraform/outputs.tf` | Role-to-IP mapping used to build the inventory |
| `ansible/gen-inventory.sh` | Writes `inventory.ini` from Terraform outputs, so no IP is typed by hand |
| `ansible/inventory.ini` | Hosts grouped into `web`, `app` and `db` |

## How to run

```bash
export AWS_PROFILE=dmi
export TF_VAR_controller_cidr="$(curl -s https://checkip.amazonaws.com)/32"
cd terraform && terraform init && terraform validate && terraform plan -out=tfplan && terraform apply tfplan
cd ../ansible && ./gen-inventory.sh
ansible all -i inventory.ini -m ping
```

Tear down with `terraform destroy` from `terraform/` once the lab is finished.

## Security choices

- The controller IP is passed at runtime through `TF_VAR_controller_cidr` and never committed.
- SSH is restricted to that single /32. HTTP is attached only to web hosts through a separate security group.
- Instances require IMDSv2 and use encrypted gp3 root volumes.
- Login is by ED25519 key only; no passwords are used anywhere.
