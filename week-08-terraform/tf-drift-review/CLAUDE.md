# CLAUDE.md: Terraform Drift and Policy Review

Owner: Oluwagbade Odimayo (DMI Cohort 3, Week 8, Assignment 6)

## Project Overview
- This workspace reviews the Terraform project in `../terraform-aws-vm` (AWS, eu-west-2): VPC, public and private subnets, Internet Gateway, public route table, security group (SSH from the owner's IP only, HTTP from anywhere) and one EC2 instance running Nginx.
- Terraform state is local to `../terraform-aws-vm`; variable values come from `local.auto.tfvars` (git-ignored).
- Evidence script: `AI Assignment/tf-drift-check.sh`. Reports: `reports/`. Skill: `/tf-drift-review`.
- A `PreToolUse` hook blocks `terraform apply` while `reports/latest-report.txt` shows `Overall Status: FAIL`.

## Review Workflow
Gather --> Analyze --> Human Reviews and Acts --> Verify
1. **Gather:** run `bash "AI Assignment/tf-drift-check.sh"`. It runs `terraform plan -detailed-exitcode`, exports plan JSON when changes are pending, and applies the jq policy checks.
2. **Analyze:** read `reports/latest-report.txt` and, if it exists, `reports/tfplan.json`. Classify each change as true infrastructure drift (`main.tf` unchanged, real resources differ) or a configuration change (`git diff` shows `main.tf` edited).
3. **Human acts:** recommend exact commands for the human to review and run. Never run them yourself.
4. **Verify:** after the human acts, run the script again. Only `Overall Status: HEALTHY` closes a review.

Valid evidence is limited to: the script's output, files in `reports/`, `main.tf`, and read-only `git diff` / `git status`. Assumptions, earlier conversations and general AWS knowledge are not evidence.

## Safety Rules
- **No evidence, no verdict:** never call a change safe, or the environment healthy, unless you can quote the report line or plan JSON field that proves it. If the plan failed or evidence is missing, say "cannot determine" and stop.
- Never run `terraform apply`, `terraform destroy`, any command with `-auto-approve`, `terraform import`, `state rm/mv`, `taint` or `force-unlock`, or any AWS CLI command that creates, changes or deletes resources.
- Never edit `.tf` files, tfvars, state files, the script or the hook. This workspace is read-only for you.
- The human owns every infrastructure change. If the human explicitly tells you to run a command, the `PreToolUse` hook has the final say: accept a block and never try to work around it.
- Never print secrets, access keys, account IDs or the owner's IP address. Show any CIDR other than `0.0.0.0/0` or `::/0` as `<owner IP>`.

## Output Rules
- First line: `Overall Status:` copied exactly from the report.
- Then these sections, in order: **Evidence** (report lines and plan fields), **Findings** (resource address, action, what changed), **Classification** (true drift or configuration change, with the proof), **Risk** (Low / Medium / High and why), **Recommendation** (commands labelled "for the human to run"), **Verification** (what must be true afterwards).
- Plain English, no speculation, under 40 lines.
