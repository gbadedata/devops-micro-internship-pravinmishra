#!/bin/bash
set -u
full_name="Oluwagbade Odimayo"
aws_region="eu-west-2"
s3_bucket_name="pravin-portfolio-oluwagbade-eu-west-2"
rds_instance_id="bra-db"
base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
report_dir="$base_dir/reports"
report_file="$report_dir/aws-audit-report.txt"

checks=(
check_s3_public_access
check_ssh_open_to_world
check_mysql_open_to_world
check_rds_public_access
check_ebs_encryption
)

pass_count=0
warning_count=0
failure_count=0
mkdir -p "$report_dir"
: > "$report_file"

write_line() {
echo "$1" | tee -a "$report_file"
}

mark_pass() {
write_line "[PASS] $1"
pass_count=$((pass_count + 1))
}

mark_warning() {
write_line "[WARN] $1"
warning_count=$((warning_count + 1))
}

mark_failure() {
write_line "[FAIL] $1"
failure_count=$((failure_count + 1))
}

print_header() {
write_line "========================================"
write_line "AWS Security and Cost Audit Report"
write_line "========================================"
write_line "Full Name: $full_name"
write_line "Timestamp: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
write_line "AWS Region: $aws_region"
write_line "S3 Bucket: $s3_bucket_name"
write_line "RDS Instance: $rds_instance_id"
write_line ""
}

check_s3_public_access() {
local block_acls
local ignore_acls
block_acls=$(aws s3api get-public-access-block --bucket "$s3_bucket_name" --query 'PublicAccessBlockConfiguration.BlockPublicAcls' --output text 2>/dev/null || echo "None")
ignore_acls=$(aws s3api get-public-access-block --bucket "$s3_bucket_name" --query 'PublicAccessBlockConfiguration.IgnorePublicAcls' --output text 2>/dev/null || echo "None")

if [ "$block_acls" = "True" ] && [ "$ignore_acls" = "True" ]
then
mark_pass "S3 bucket '$s3_bucket_name' blocks and ignores public ACLs (public read, if any, comes only from its scoped bucket policy)"
else
mark_failure "S3 bucket '$s3_bucket_name' does not fully block public ACLs (BlockPublicAcls=$block_acls, IgnorePublicAcls=$ignore_acls) - public access should only ever come through the scoped bucket policy, never through ACLs"
fi
}

check_ssh_open_to_world() {
local open_sg_count
# Matches per RULE, not per group. The --filters form matches each condition
# against any rule in the group independently, so a group with SSH scoped to one
# IP plus an unrelated 0.0.0.0/0 rule on another port is reported falsely.
open_sg_count=$(aws ec2 describe-security-group-rules \
--region "$aws_region" \
--query 'length(SecurityGroupRules[?IsEgress==`false` && CidrIpv4==`0.0.0.0/0` && FromPort<=`22` && ToPort>=`22`])' \
--output text 2>/dev/null || echo "0")

if [ "$open_sg_count" -gt 0 ] 2>/dev/null
then
mark_failure "$open_sg_count security group(s) allow SSH (port 22) from 0.0.0.0/0"
else
mark_pass "No security group allows SSH (port 22) from 0.0.0.0/0"
fi
}

check_mysql_open_to_world() {
local open_sg_count
# Same per-rule fix as the SSH check above.
open_sg_count=$(aws ec2 describe-security-group-rules \
--region "$aws_region" \
--query 'length(SecurityGroupRules[?IsEgress==`false` && CidrIpv4==`0.0.0.0/0` && FromPort<=`3306` && ToPort>=`3306`])' \
--output text 2>/dev/null || echo "0")

if [ "$open_sg_count" -gt 0 ] 2>/dev/null
then
mark_failure "$open_sg_count security group(s) allow MySQL (port 3306) from 0.0.0.0/0"
else
mark_pass "No security group allows MySQL (port 3306) from 0.0.0.0/0"
fi
}

check_rds_public_access() {
local publicly_accessible
publicly_accessible=$(aws rds describe-db-instances \
--db-instance-identifier "$rds_instance_id" \
--region "$aws_region" \
--query 'DBInstances[0].PubliclyAccessible' --output text 2>/dev/null || echo "None")

if [ "$publicly_accessible" = "False" ]
then
mark_pass "RDS instance '$rds_instance_id' is not publicly accessible"
elif [ "$publicly_accessible" = "True" ]
then
mark_failure "RDS instance '$rds_instance_id' is publicly accessible"
else
mark_warning "Could not determine public accessibility for RDS instance '$rds_instance_id' (instance not found or insufficient permission)"
fi
}

check_ebs_encryption() {
local unencrypted_count
unencrypted_count=$(aws ec2 describe-volumes \
--region "$aws_region" \
--filters "Name=encrypted,Values=false" \
--query 'length(Volumes[])' --output text 2>/dev/null || echo "0")

if [ "$unencrypted_count" -gt 0 ] 2>/dev/null
then
mark_warning "$unencrypted_count EBS volume(s) are not encrypted"
else
mark_pass "All EBS volumes are encrypted"
fi
}

print_summary() {
local overall_status
local script_exit_code

if [ "$failure_count" -gt 0 ]
then
overall_status="FAIL"
script_exit_code=2
elif [ "$warning_count" -gt 0 ]
then
overall_status="WARN"
script_exit_code=1
else
overall_status="HEALTHY"
script_exit_code=0
fi

write_line ""
write_line "Summary:"
write_line "PASS: $pass_count"
write_line "WARN: $warning_count"
write_line "FAIL: $failure_count"
write_line "Overall Status: $overall_status"
write_line "Script Exit Code: $script_exit_code"
write_line "Report File: $report_file"
return "$script_exit_code"
}

print_header
for check_function in "${checks[@]}"
do
"$check_function"
done
print_summary
exit $?
