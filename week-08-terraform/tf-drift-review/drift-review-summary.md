# Terraform Drift Review Summary

**Reviewer:** Oluwagbade Odimayo
**Environment:** `week-08-terraform/terraform-aws-vm` (AWS eu-west-2: VPC, subnets, IGW, route table, security group, EC2 with Nginx)
**Date:** 24 September 2026

## 1. Change Introduced
In `main.tf` I changed the SSH ingress rule on `aws_security_group.web` from `cidr_blocks = [var.my_ip_cidr]` to `cidr_blocks = ["0.0.0.0/0"]`, opening port 22 to the whole internet. This was a **Terraform configuration change, not true infrastructure drift**: I edited the code, while the real security group in AWS was never touched. `git diff` showed the edit, and the change was never applied.

## 2. Evidence Collected
- `terraform plan -detailed-exitcode` returned exit code **2** with `Plan: 0 to add, 1 to change, 0 to destroy.`
- `reports/tfplan.json` listed one change: `aws_security_group.web` with action `update` (in place, no delete).
- The only attribute that differed was `ingress`: the 22/tcp rule's `cidr_blocks` went from my own IP to `0.0.0.0/0`. The port 80 rule was unchanged.

## 3. Risk Assessment
- The Bash checks returned `[PASS] check_destructive_actions` (nothing deleted or replaced) and `[FAIL] check_open_ingress` (`aws_security_group.web allows tcp ports 22-22 from the internet`), so the overall status was **FAIL**.
- Claude Code rated the risk **High**: applying it would expose SSH on the EC2 instance to every address on the internet. It also noticed that the rule's description still said "SSH from my public IP", which would no longer be true.

## 4. Human-Approved Action
I reviewed the plan and Claude's recommendation, then chose not to apply the change. I reverted the configuration myself with `git checkout -- main.tf` and confirmed with `terraform plan` that nothing was pending. No `terraform apply` was needed, because the risky change had only ever existed in code. When I instructed Claude Code to run `terraform apply` while the report said FAIL, the `PreToolUse` hook blocked it before Terraform ran.

## 5. Verification
- A second `/tf-drift-review` returned **Overall Status: HEALTHY**: script exit code 0, plan exit code 0, all three checks PASS, no `tfplan.json` created, and an empty `git diff` on `main.tf`. This is saved as `reports/resolved-report.txt`.
- Lesson from verification: my first verification plan ran in a new terminal still using my default AWS profile, which points at a different account. Terraform could not find the resources there and proposed recreating all 9. Reading the plan before acting caught it; I switched to the correct profile and got `No changes`. Checking which account a plan runs against is now part of my routine.

## 6. Safety Decision
Claude was allowed to gather and analyse evidence because those steps are read-only and repeatable: running `terraform plan`, reading JSON, and comparing `git diff`. It was not allowed to change infrastructure because `apply` affects real systems, cannot always be undone, and depends on context an agent can get wrong (as the wrong-account plan showed). `CLAUDE.md` and the skill's rules keep Claude read-only, and the `PreToolUse` hook enforces the gate deterministically even when Claude is told to run `apply`.

## 7. Agentic Loop Mapping
- **Gather:** `tf-drift-check.sh` ran `terraform plan -detailed-exitcode`, exported plan JSON and applied the jq policy checks.
- **Analyze:** `/tf-drift-review` read the report and plan JSON, classified the change using `git diff`, rated the risk and recommended a fix.
- **Human Act:** I reviewed the evidence and reverted `main.tf` myself; the hook blocked an apply attempt through Claude.
- **Verify:** a second `/tf-drift-review` confirmed HEALTHY, saved as `resolved-report.txt`.
