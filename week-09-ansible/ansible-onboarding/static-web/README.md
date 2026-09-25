# Static Website: Multi-Play Ansible Deployment

**Owner:** Oluwagbade Odimayo

**Cloud:** AWS (eu-west-2), reusing web1 and web2 from the Assignment 02 Terraform lab

## What this project does

One Ansible playbook installs Nginx on two Ubuntu servers, deploys a personalised static website to both,
and then checks from the controller that each server returns HTTP 200.

| Server | Public URL |
|---|---|
| web1 | http://35.176.126.122 |
| web2 | http://18.135.15.215 |

## Files

| File | Purpose |
|---|---|
| `inventory.ini` | `[web]` group with web1 and web2, built from the Assignment 02 Terraform outputs |
| `site.yml` | Three plays: install, deploy, verify |
| `files/index.html` | The website, downloaded from `pravinmishraaws/Azure-Static-Website` with my name in the footer |

## How the playbook works

1. **Play 1 (hosts: web)** installs Nginx with `apt` and makes sure the service is started and enabled at boot.
   `cache_valid_time: 3600` stops the package index being refreshed on every run.
2. **Play 2 (hosts: web)** copies `files/index.html` to `/var/www/html/index.html`, owned by `www-data`
   with mode `0644`. If the file changes, it notifies a handler that reloads Nginx.
3. **Play 3 (hosts: localhost)** requests the home page of every host in the `web` group with the `uri`
   module, prints the status for each, and asserts that all of them returned HTTP 200.

## How to run

```bash
export ANSIBLE_CONFIG=~/DMI/ansible-onboarding/ansible.cfg
ansible-playbook -i inventory.ini site.yml --syntax-check
ansible-playbook -i inventory.ini site.yml
```

## Results

- First deployment: web1 and web2 each reported `changed=2` (the page copy and the Nginx reload), with
  `failed=0` and `unreachable=0`. Play 1 reported `ok` because Nginx was already installed in Assignment 02.
- Second run: `changed=0` on both servers, proving the playbook is idempotent.
- `curl -I` and a browser both returned the site with HTTP 200 from each public IP.

## What I learned

- Splitting install, deploy and verify into separate plays keeps each concern readable, and lets the
  verification run from the controller, which is where a real user's request comes from.
- A handler only runs when something it watches has changed, so the Nginx reload happened on the first
  deployment and was skipped on the rerun.
- Idempotency means the playbook describes a desired state rather than a list of steps. When I removed
  `index.html` from both servers, the next run put it back and reloaded Nginx; when nothing had drifted,
  the same run changed nothing.
