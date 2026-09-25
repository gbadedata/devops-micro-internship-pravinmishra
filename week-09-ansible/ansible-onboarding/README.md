# Ansible Onboarding Workstation

**Owner:** Oluwagbade Odimayo

**Programme:** DevOps Micro Internship (DMI) Cohort 3, Week 9: Ansible

## Summary

This repository is a reusable, team-ready Ansible controller workspace. Ansible and its
validation tools run inside a project-local Python virtual environment, so the system Python is
never touched and every teammate gets the same pinned versions from `requirements.txt`.
VS Code, EditorConfig, a baseline `ansible.cfg`, SSH defaults and pre-commit hooks are all
configured so that a new machine can be brought to the same state by following one checklist.
This workstation is the Ansible controller for the rest of the Week 9 assignments.

## New Machine? Do This

- [ ] 1. Install prerequisites: `sudo apt update && sudo apt install -y git python3-venv`
- [ ] 2. Copy or clone this workspace to `~/DMI/ansible-onboarding` and `cd` into it
- [ ] 3. Create and activate the virtual environment: `python3 -m venv .venv && source .venv/bin/activate`
- [ ] 4. Install the pinned tools: `pip install -r requirements.txt`
- [ ] 5. Confirm Ansible uses this project's config: `ansible --version` shows `config file = .../ansible-onboarding/ansible.cfg`
- [ ] 6. Create an SSH key if you have none: `ssh-keygen -t ed25519 -C "you@example.com"` (never share or commit the private key)
- [ ] 7. Add the `Host *` defaults block to the end of `~/.ssh/config` (IdentityFile, IdentitiesOnly, AddKeysToAgent, ServerAlive, StrictHostKeyChecking accept-new)
- [ ] 8. Load the key and confirm: `ssh-add ~/.ssh/id_ed25519 && ssh-add -l`
- [ ] 9. Set Git identity: `git config --global user.name "Your Name"`, `user.email`, and `init.defaultBranch main`
- [ ] 10. Install the Git hooks: `pre-commit install`
- [ ] 11. Validate everything: `git add -A && pre-commit run --all-files` shows every hook `Passed`
- [ ] 12. Open VS Code with `code .`, install the Ansible, YAML and Python extensions, and select `./.venv/bin/python` as the interpreter

## Workstation details

| Item | Value |
|---|---|
| OS | Ubuntu 24.04 on WSL2 (Windows host) |
| Python | 3.12.3 in `.venv/` |
| Ansible | ansible 14.4.0 (ansible-core 2.21.4) |
| Linting | ansible-lint 26.9.0, yamllint 1.38.0 |
| Git hooks | pre-commit 4.6.2 |
| Editor | VS Code 1.139.0 with Ansible (Red Hat), YAML (Red Hat) and Python (Microsoft) extensions |
| SSH key | ED25519, loaded into a shared ssh-agent |

## Project structure

| Path | Purpose |
|---|---|
| `ansible.cfg` | Baseline settings: inventory path, roles path, SSH key, forks, pipelining, safe host-key handling |
| `inventories/hosts.ini` | Controller self-test inventory (localhost only); each lab uses its own inventory |
| `roles/` | Home for reusable roles in later assignments |
| `requirements.txt` | Pinned Python tooling versions |
| `.pre-commit-config.yaml` | Hooks: whitespace, end-of-file, YAML syntax, large files, private-key detection, yamllint, ansible-lint |
| `.yamllint`, `.ansible-lint` | Lint rules (ansible-lint `production` profile) |
| `.editorconfig`, `.vscode/settings.json` | Consistent formatting and editor tooling pointed at `.venv` |
| `.gitignore` | Keeps `.venv/`, keys, vault files and runtime artefacts out of Git |

## Design decisions

- **Virtual environment, not system Python.** Upgrading Ansible for one project cannot break
  another, and `pip install -r requirements.txt` reproduces the exact toolset anywhere.
- **`StrictHostKeyChecking=accept-new` instead of disabling host key checks.** New servers are
  trusted on first contact, but a changed key on a known server is refused.
- **`become = False` by default.** Root access is requested explicitly per task or command.
- **Hooks pinned to exact versions.** Every machine runs identical checks. The ansible-lint hook
  is set to `language_version: python3` because the upstream hook requests Python 3.14.
