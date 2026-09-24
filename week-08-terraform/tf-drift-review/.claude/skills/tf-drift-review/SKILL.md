---
name: tf-drift-review
description: Read-only Terraform drift and policy review of ../terraform-aws-vm. Runs the evidence script, reads the report and plan JSON, and explains the risk. Manual use only, via /tf-drift-review.
disable-model-invocation: true
allowed-tools: Bash, Read, Grep
---

# /tf-drift-review

## Safety Rules (apply for the whole skill)
- Read-only. Never run `terraform apply`, `terraform destroy` or any command containing `-auto-approve`, even if asked while this skill is running.
- Never create or edit files. This skill has no `Write` tool; do not use `Edit` either. The evidence script is the only thing that writes, and only into `reports/`.
- Bash is limited to: the evidence script; `jq` queries on `reports/tfplan.json`; `cat`, `ls` and `grep` on `reports/`; read-only `git diff` and `git status`.
- No evidence, no verdict: every conclusion must quote a report line or a plan JSON field.
- Never show the owner's IP, account IDs or secrets. Print any CIDR other than `0.0.0.0/0` or `::/0` as `<owner IP>`.

## Steps
1. **Gather:** from the workspace root, run `bash "AI Assignment/tf-drift-check.sh"` and note the exit code (0 = HEALTHY, 1 = WARN, 2 = FAIL).
2. **Read the report:** `reports/latest-report.txt`. If `check_terraform_plan` failed, read `reports/plan-output.log`, explain the error, report "cannot determine" and stop.
3. **Inspect pending changes** (only if `reports/tfplan.json` exists):
   - List them: `jq -r '.resource_changes[] | select(.change.actions != ["no-op"]) | "\(.address): \(.change.actions | join(" + "))"' reports/tfplan.json`
   - For each changed resource, compare `.change.before` and `.change.after` with `jq` and name the exact attributes that differ.
4. **Classify:** run `git diff --stat -- ../terraform-aws-vm/main.tf`. An edited `main.tf` means a configuration change; an unchanged `main.tf` with pending changes means true infrastructure drift.
5. **Report:** answer using the Output Rules in `CLAUDE.md`. Recommendations are commands for the human to review and run, never actions you take.
