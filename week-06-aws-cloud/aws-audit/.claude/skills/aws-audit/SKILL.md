---
name: aws-audit
description: Run the read-only AWS security and cost audit script, analyze its evidence, and produce a concise findings report with recommended (not executed) remediation commands.
allowed-tools: Bash, Read, Grep
disable-model-invocation: true
---

# AWS Audit Skill

When `/aws-audit` is invoked:
1. Read `CLAUDE.md` before doing anything else.
2. Run `bash scripts/aws-audit.sh || true`.
3. Read `reports/aws-audit-report.txt`.
4. Report the following:
- Overall status
- Every WARN or FAIL result
- Exact evidence from the report (resource name, region, the field that failed)
- For each FAIL or WARN, the estimated monthly cost or risk impact of leaving it as-is (for example: an unencrypted EBS volume carries no extra AWS charge but is a compliance/audit risk; a publicly accessible RDS instance is a security risk, not a cost one; an oversized or idle EC2 instance left running is a direct monthly cost)
- One exact, safe AWS CLI remediation command per finding for the human to review (for example: `aws ec2 revoke-security-group-ingress --group-id <sg-id> --protocol tcp --port 22 --cidr 0.0.0.0/0`)
- One verification command to confirm the fix afterward

5. If every check passes, clearly state that no remediation action is required.
6. Do not edit files.
7. Do not run any AWS CLI command that creates, modifies, deletes, stops, or terminates a resource (no `revoke-security-group-ingress`, `authorize-security-group-ingress`, `modify-db-instance`, `terminate-instances`, `put-public-access-block`, etc. - read-only `describe-*`, `get-*`, and `list-*` calls only).
8. Never execute the recommended remediation command yourself.
9. Ask the human to review and run any remediation action manually.
