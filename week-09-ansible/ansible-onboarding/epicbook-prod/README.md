# EpicBook: Production-Style Deployment with Terraform and Ansible Roles

**Owner:** Oluwagbade Odimayo

**Cloud:** AWS (eu-west-2, London)

**Application URL (while deployed):** http://13.135.253.192

## Architecture

```text
Browser --HTTP 80--> Nginx (reverse proxy) --> EpicBook Node.js on 8080 (PM2) --MySQL 3306--> Amazon RDS (private)
```

| Layer | Tool | What it provides |
|---|---|---|
| Infrastructure | Terraform (`terraform/aws/`) | VPC, public subnet, two private DB subnets, Ubuntu 24.04 `t3.micro`, RDS MySQL 8.0 `db.t3.micro` |
| Configuration | Ansible roles (`ansible/roles/`) | `common` base packages, `nginx` reverse proxy, `epicbook` app, database and PM2 |

## Security design

- SSH (22) is allowed only from the controller's public IP; HTTP (80) is open for visitors.
- MySQL (3306) is allowed **only** from the app server's security group. The database has no public IP.
- The database password is generated locally into `~/.config/dmi/` (outside the repository) and reaches
  Terraform and Ansible only through environment variables. It is never committed, never a Terraform output,
  and Ansible writes it with `no_log` into a `0600` PM2 ecosystem file on the server.
- The AWS account ID sits in a git-ignored `local.auto.tfvars` and `allowed_account_ids` stops Terraform
  from running against any other account.

## Ansible roles (run in this order)

| Role | Responsibility |
|---|---|
| `common` | Waits for cloud-init, installs `git`, `curl`, `acl` and `mysql-client` |
| `nginx` | Installs Nginx, deploys `epicbook.conf.j2` (port 80 to `app_port`), disables the default site, validates with `nginx -t` |
| `epicbook` | Installs Node.js, npm and PM2, clones the app, writes the PM2 ecosystem file with the database URL, installs dependencies, imports the schema and seed data once, starts the app under PM2 and registers it to start at boot |

Settings shared by the roles live in `ansible/group_vars/web.yml`.

## How to run

```bash
# Secrets and guardrails (once per terminal)
export AWS_PROFILE=dmi
export TF_VAR_db_password="$(cat ~/.config/dmi/epicbook-prod-db.pass)"
export EPICBOOK_DB_PASSWORD="$TF_VAR_db_password"
export TF_VAR_controller_cidr="$(curl -s https://checkip.amazonaws.com)/32"

# Infrastructure
cd terraform/aws
terraform init && terraform validate && terraform plan -out=tfplan && terraform apply tfplan

# Configuration and deployment
cd ../../ansible
export EPICBOOK_DB_HOST="$(terraform -chdir=../terraform/aws output -raw db_endpoint)"
ansible web -i inventory.ini -m ping
ansible-playbook -i inventory.ini site.yml
```

## Results

- Terraform: `Plan: 13 to add`, then `Apply complete! Resources: 13 added`.
- First playbook run: `ok=25 changed=15 failed=0 unreachable=0`.
- Second run: `changed=0`, with the schema import, PM2 start and npm install correctly skipped.
- Nginx `active`, PM2 shows `epicbook` online, `curl -I http://localhost:8080` returns 200 on the VM.
- From the controller: the public URL returns 200 through Nginx, `POST /api/cart` returns a cart row with
  a seeded book from RDS, and `/cart` returns 200.

## Design decisions worth noting

- EpicBook ships `config/config.json` inside its Git repository. Writing credentials there makes the
  checkout "dirty" and every later `git` task fails, so the role uses the app's production mode instead:
  the database URL goes into a PM2 ecosystem file outside the repository.
- The schema file has no `IF NOT EXISTS`, so the role checks `information_schema` first and imports the
  schema and seed data only on the first deployment.
- `npm install` runs only when the code changes or `node_modules` is missing, which keeps reruns at `changed=0`.
