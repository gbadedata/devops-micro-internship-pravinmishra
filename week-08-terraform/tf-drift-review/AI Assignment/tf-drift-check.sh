#!/usr/bin/env bash
# tf-drift-check.sh: read-only Terraform drift and policy check.
# Gathers evidence with terraform plan and plan JSON, then checks it with jq.
# This script NEVER runs terraform apply, terraform destroy, or -auto-approve.
#
# Usage: bash "AI Assignment/tf-drift-check.sh" [report-name.txt]
# Exit codes: 0 = HEALTHY, 1 = WARN, 2 = FAIL

set -uo pipefail

STUDENT_NAME="Oluwagbade Odimayo"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
TF_DIR="$(cd "$WORKSPACE_DIR/../terraform-aws-vm" && pwd)"
REPORT_DIR="$WORKSPACE_DIR/reports"
PLAN_BIN="$REPORT_DIR/tfplan.bin"
PLAN_JSON="$REPORT_DIR/tfplan.json"
PLAN_LOG="$REPORT_DIR/plan-output.log"
LATEST_REPORT="$REPORT_DIR/latest-report.txt"
ALLOWED_OPEN_PORTS="80 443"
SAVE_AS="${1:-}"

checks=(
  "check_terraform_plan"
  "check_destructive_actions"
  "check_open_ingress"
)

overall="HEALTHY"
results=()

# Record a result and raise the overall status (HEALTHY < WARN < FAIL, never lowered)
record() {
  local level="$1" name="$2" detail="$3"
  results+=("[$level] $name: $detail")
  if [[ "$level" == "FAIL" ]]; then
    overall="FAIL"
  elif [[ "$level" == "WARN" && "$overall" == "HEALTHY" ]]; then
    overall="WARN"
  fi
}

# Evidence: plan -detailed-exitcode returns 0 = no changes, 1 = error, 2 = changes pending
check_terraform_plan() {
  rm -f "$PLAN_BIN" "$PLAN_JSON"
  terraform -chdir="$TF_DIR" plan -detailed-exitcode -input=false -no-color -out="$PLAN_BIN" > "$PLAN_LOG" 2>&1
  local plan_exit=$?
  case "$plan_exit" in
    0)
      rm -f "$PLAN_BIN"
      record "PASS" "check_terraform_plan" "No changes. Infrastructure matches the configuration (plan exit code 0)."
      ;;
    2)
      terraform -chdir="$TF_DIR" show -json "$PLAN_BIN" > "$PLAN_JSON"
      local summary
      summary="$(grep -E '^Plan:' "$PLAN_LOG" || echo 'Plan summary line not found')"
      record "WARN" "check_terraform_plan" "Changes pending (plan exit code 2). $summary"
      ;;
    *)
      record "FAIL" "check_terraform_plan" "terraform plan failed (exit code $plan_exit). See reports/plan-output.log."
      ;;
  esac
}

# Policy 1: any delete action. Replacements also appear here, as delete + create.
check_destructive_actions() {
  if [[ ! -f "$PLAN_JSON" ]]; then
    record "PASS" "check_destructive_actions" "No plan JSON (no pending changes), so nothing will be deleted."
    return
  fi
  local hits
  hits="$(jq -r '
    .resource_changes[]?
    | select(.change.actions | index("delete"))
    | "\(.address) (\(.change.actions | join(" + ")))"
  ' "$PLAN_JSON")"
  if [[ -n "$hits" ]]; then
    record "FAIL" "check_destructive_actions" "Delete or replace pending: $(paste -sd ';' <<< "$hits")"
  else
    record "PASS" "check_destructive_actions" "No delete or replace actions in the plan."
  fi
}

# Policy 2: created or updated ingress open to the internet on any port except 80/443
check_open_ingress() {
  if [[ ! -f "$PLAN_JSON" ]]; then
    record "PASS" "check_open_ingress" "No plan JSON (no pending changes), so no ingress changes."
    return
  fi
  local hits
  hits="$(jq -r --arg allowed "$ALLOWED_OPEN_PORTS" '
    ($allowed | split(" ") | map(tonumber)) as $ok
    | def allowed_port: .from_port == .to_port and (.from_port as $p | $ok | index($p) != null);
    .resource_changes[]?
    | select(.change.actions | (index("create") != null or index("update") != null))
    | . as $rc
    | if .type == "aws_security_group" then
        (.change.after.ingress // [])[]
        | select(((.cidr_blocks // []) | index("0.0.0.0/0") != null)
                 or ((.ipv6_cidr_blocks // []) | index("::/0") != null))
        | select(allowed_port | not)
        | "\($rc.address) allows \(.protocol) ports \(.from_port)-\(.to_port) from the internet"
      elif .type == "aws_vpc_security_group_ingress_rule" then
        .change.after
        | select(.cidr_ipv4 == "0.0.0.0/0" or .cidr_ipv6 == "::/0")
        | select(allowed_port | not)
        | "\($rc.address) allows \(.ip_protocol) ports \(.from_port)-\(.to_port) from the internet"
      else empty end
  ' "$PLAN_JSON")"
  if [[ -n "$hits" ]]; then
    record "FAIL" "check_open_ingress" "Unsafe ingress: $(paste -sd ';' <<< "$hits")"
  else
    record "PASS" "check_open_ingress" "No new internet-open ingress outside ports ${ALLOWED_OPEN_PORTS// / and }."
  fi
}

mkdir -p "$REPORT_DIR"
for check in "${checks[@]}"; do
  "$check"
done

{
  echo "=================================================="
  echo " Terraform Drift and Policy Review"
  echo "=================================================="
  echo "Reviewer      : $STUDENT_NAME"
  echo "Generated     : $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  echo "Terraform dir : week-08-terraform/$(basename "$TF_DIR")"
  if [[ -f "$PLAN_JSON" ]]; then
    echo "Plan JSON     : reports/tfplan.json"
  else
    echo "Plan JSON     : not created (no pending changes, or plan error)"
  fi
  echo "--------------------------------------------------"
  printf '%s\n' "${results[@]}"
  echo "--------------------------------------------------"
  echo "Overall Status: $overall"
  echo "Read-only review: any terraform apply is a human decision."
} | tee "$LATEST_REPORT"

if [[ -n "$SAVE_AS" ]]; then
  cp "$LATEST_REPORT" "$REPORT_DIR/$SAVE_AS"
  echo "Saved copy: reports/$SAVE_AS"
fi

case "$overall" in
  HEALTHY) exit 0 ;;
  WARN)    exit 1 ;;
  *)       exit 2 ;;
esac
