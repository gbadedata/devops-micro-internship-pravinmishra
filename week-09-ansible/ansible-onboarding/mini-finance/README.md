# Mini Finance on Azure with Terraform and Ansible

**Owner:** Oluwagbade Odimayo

**Live URL (while deployed):** http://51.137.182.18

## What this project does

Terraform provisions an Ubuntu 24.04 VM on Azure with the networking and security it needs. Ansible then
installs Nginx, Git and rsync, clones the Mini Finance website from GitHub, deploys it to the Nginx web
root and verifies from the controller that the site is live.

## Infrastructure (Terraform, `terraform/`)

| Resource | Name | Purpose |
|---|---|---|
| Resource group | `rg-mini-finance` | Holds every resource, so the whole stack is removed in one destroy |
| Virtual network and subnet | `vnet-mini-finance`, `snet-mini-finance` | Private network for the VM (10.30.0.0/16) |
| Public IP | `pip-mini-finance` | Static Standard IP for SSH and HTTP access |
| Network security group | `nsg-mini-finance` | `Allow-SSH` (22) from my IP only, `Allow-HTTP` (80) from anywhere |
| Network interface | `nic-mini-finance` | Connects the VM to the subnet; the NSG is associated with it |
| Virtual machine | `vm-mini-finance` | Ubuntu 24.04, `Standard_B1s`, hostname `mini-finance`, SSH key login only |

My public IP and the subscription ID are supplied through environment variables
(`TF_VAR_controller_cidr`, `ARM_SUBSCRIPTION_ID`) and never written to a file.

## Configuration and deployment (Ansible, `ansible/`)

| Play | Hosts | What it does |
|---|---|---|
| Play 1 | `web` | Installs `nginx`, `git` and `rsync`; makes sure Nginx is started and enabled |
| Play 2 | `web` | Clones `pravinmishraaws/mini_finance`, rsyncs it into `/var/www/html/` owned by `www-data:www-data` (excluding `.git`), reloads Nginx through a handler when files change |
| Play 3 | `localhost` | Requests the site with the `uri` module and asserts HTTP 200 and that the Mini Finance page is returned |

## How to run

```bash
# Infrastructure
cd terraform
export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
export TF_VAR_controller_cidr="$(curl -s https://checkip.amazonaws.com)/32"
terraform fmt && terraform init && terraform validate
terraform plan -out=tfplan && terraform apply tfplan

# Deployment
cd ../ansible
export ANSIBLE_CONFIG=~/DMI/ansible-onboarding/ansible.cfg
ansible web -i inventory.ini -m ping
ansible-playbook -i inventory.ini site.yml --syntax-check
ansible-playbook -i inventory.ini site.yml
```

Tear down with `terraform destroy` from `terraform/` once finished.

## Results

- Terraform: `Plan: 8 to add`, then `Apply complete! Resources: 8 added`.
- SSH: `ssh -i ~/.ssh/id_rsa azureuser@<public_ip> hostname` returned `mini-finance` with no password.
- Ansible: `ping` returned `pong`; the playbook finished with `failed=0` and `unreachable=0`, and Play 3
  confirmed HTTP 200 and the Mini Finance page.
- The site loaded in a browser at the VM's public IP.

## What I learned

- Terraform and Ansible have separate jobs: Terraform decides what exists, Ansible decides what runs on it.
  The only hand-off between them is the `public_ip` output, which I used to generate the inventory.
- Deploying with `rsync` from a clone on the server copies only changed files, removes files that no longer
  exist in the repository, and keeps `.git` out of the public web root.
- Verifying from the controller with `uri` tests what a visitor experiences, including the NSG rule for
  port 80, not just whether the Nginx service is running.
