# Project Overview
This project builds a read-only AWS security-and-cost audit workflow for the personal AWS Free Tier resources built during Week 6 (S3 static site, EC2 instance(s), RDS database, security groups).
The Bash script is responsible for collecting evidence using read-only AWS CLI calls. Claude Code is responsible for analyzing that evidence, estimating cost/risk impact, and explaining a safe remediation command.

# Audit Workflow
Always follow this order:
1. Gather evidence using read-only AWS CLI calls only
2. Analyze the evidence and estimate cost/risk impact
3. Ask the human to approve and execute any remediation command
4. Verify the account again

# Safety Rules
- Never create, modify, delete, stop, start, or terminate any AWS resource.
- Never run aws ec2 terminate-instances, aws rds delete-db-instance, or aws s3 rb.
- Never run aws ec2 revoke-security-group-ingress, aws ec2 authorize-security-group-ingress, or aws rds modify-db-instance.
- Use only the Bash audit report as the primary source of evidence.
- Recommend a remediation command, but do not execute it.
- Do not claim a finding unless the report contains supporting evidence.

# Output Rules
When analyzing a report, show:
1. Overall status
2. Every WARN or FAIL finding
3. Exact evidence from the report
4. Estimated monthly cost or risk impact for each finding
5. One safe remediation command for the human to review
6. One verification command
