# CLAUDE.md: Ansible Change Risk Review for EpicBook

Owner: Oluwagbade Odimayo (DMI Cohort 3, Week 9, Assignment 6)

## Project Overview
- This workspace reviews pending changes to the EpicBook Ansible project in `../ansible`
  (roles `common`, `nginx`, `epicbook`; inventory `../ansible/inventory.ini`; config `../ansible/ansible.cfg`).
- The target is one live Ubuntu 24.04 server on AWS (eu-west-2) running Nginx and EpicBook under PM2,
  backed by a private Amazon RDS for MySQL database.
- Evidence script: `./ansible-check-review.sh`. Reports: `reports/`. Skill: `/ansible-risk-review`.
- A `PreToolUse` hook blocks any `ansible-playbook` command that does not include `--check`.

## Review Workflow
Gather --> Analyze --> Human Reviews and Applies --> Verify
1. **Gather:** run `./ansible-check-review.sh` (optionally with a report path). It runs
   `ansible-playbook --check --diff` (a dry run), writes the full output to `reports/dry-run-output.log`
   and a classified summary to the report file.
2. **Analyze:** read the report and the dry-run log. For every changed task, name the file it would
   change, quote the diff lines, and explain the risk using the four categories below.
3. **Human applies:** recommend the exact command for the human to run in their own terminal. Never run it.
4. **Verify:** after the human applies, run the script again. Only `Overall Status: HEALTHY` closes a review.

## Risk Categories
- **HIGH - Access and security:** SSH, users, keys, sudoers, firewall. A mistake can lock everyone out.
- **HIGH - Destructive or data change:** deleting files or packages, schema or database changes.
- **MEDIUM - Service disruption:** restarts, reloads, stops of Nginx, SSH, PM2 or EpicBook.
- **LOW - Configuration or package change:** templates, packages, clones and other routine changes.

## Safety Rules
- **Dry run only:** never run `ansible-playbook` without `--check`, and never run `ansible` ad-hoc commands
  that change state (`--become`, `state=`, `apt`, `service`, `file`, `copy`, `lineinfile`, `shell`).
- **The human applies:** applying the playbook is always the human's decision, made in their own terminal
  after reading the report. If asked to apply, refuse and give the command for the human instead.
- **No edits:** never create, edit or delete files. The script is the only thing that writes, and only into `reports/`.
- **No evidence, no verdict:** never call a change safe unless you can quote the report line or diff that
  proves it. If the dry run failed, say "cannot determine" and stop.
- **Secrets:** never print `EPICBOOK_DB_PASSWORD`, `EPICBOOK_DB_HOST`, `TF_VAR_*`, the contents of
  `~/.config/dmi/`, or the PM2 ecosystem file.
- **Hooks have the final say:** if a hook blocks a command, accept it and never try to work around it.

## Output Rules
- First line: `Overall Status:` copied exactly from the report, with the script's exit code.
- Then, in order: **Evidence** (report and diff lines), **Changed tasks** (role, task, file affected),
  **Risk** (category and why), **Recommendation** (commands labelled "for the human to run"),
  **Verification** (what must be true after applying, including a fresh SSH login).
- Plain English, no speculation, under 40 lines.
