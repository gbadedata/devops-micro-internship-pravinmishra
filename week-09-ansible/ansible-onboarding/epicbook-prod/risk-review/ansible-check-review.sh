#!/usr/bin/env bash
# ansible-check-review.sh: read-only risk review of pending Ansible changes for EpicBook.
# Runs the playbook with --check --diff (a dry run: nothing is changed on the server),
# lists every task that WOULD change, classifies them into four risk categories,
# and writes a report. Applying the playbook is always a human decision.
#
# Usage: ./ansible-check-review.sh [report-file]      (default: reports/ansible-risk-report.txt)
# Exit codes: 0 = HEALTHY (nothing would change)
#             1 = WARNING (changes pending, none high risk: review, then decide)
#             2 = FAILED  (high-risk change pending, or the dry run itself failed: do not apply)

set -uo pipefail

full_name="Oluwagbade Odimayo"
playbook_path="${PLAYBOOK_PATH:-../ansible/site.yml}"
inventory_path="${INVENTORY_PATH:-../ansible/inventory.ini}"
report_file="${1:-reports/ansible-risk-report.txt}"
raw_log="reports/dry-run-output.log"          # full --check --diff output (git-ignored: *.log)
extra_args="${ANSIBLE_EXTRA_ARGS:-}"            # optional, used only for local testing

# Four risk categories: "SEVERITY|Category name|case-insensitive pattern matched against changed task names"
checks=(
  "HIGH|Access and security|ssh|sshd|permitrootlogin|authorized_key|firewall|ufw|iptables|sudoers|password|security"
  "HIGH|Destructive or data change|delete|remove|absent|drop|truncate|purge|schema|database|import"
  "MEDIUM|Service disruption|restart|reload|stop"
  "LOW|Configuration or package change|install|template|config|copy|package|write|deploy|clone|enable|disable"
)

changed_tasks=()   # every task (or handler) the dry run reports as "changed"

# Read the dry-run output and collect the names of tasks that would change.
extract_changed_tasks() {
  local output="$1" current="" line
  while IFS= read -r line; do
    if [[ "$line" =~ ^(TASK|RUNNING\ HANDLER)\ \[(.*)\] ]]; then
      current="${BASH_REMATCH[2]}"
    elif [[ "$line" =~ ^changed: ]] && [[ -n "$current" ]]; then
      local seen="no" t
      for t in "${changed_tasks[@]}"; do [[ "$t" == "$current" ]] && seen="yes"; done
      [[ "$seen" == "no" ]] && changed_tasks+=("$current")
    fi
  done <<< "$output"
}

# Print every changed task whose name matches a pattern (case-insensitive).
check_tasks_matching_pattern() {
  local pattern="$1" t
  for t in "${changed_tasks[@]}"; do
    if grep -qiE "$pattern" <<< "$t"; then
      echo "$t"
    fi
  done
}

# ---------- Preflight ----------
mkdir -p reports
ansible_dir="$(dirname "$playbook_path")"
for f in "$playbook_path" "$inventory_path" "$ansible_dir/ansible.cfg"; do
  [[ -f "$f" ]] || { echo "ERROR: $f not found. Run this script from the risk-review directory." >&2; exit 2; }
done
if [[ -z "${EPICBOOK_DB_HOST:-}" || -z "${EPICBOOK_DB_PASSWORD:-}" ]]; then
  echo "ERROR: export EPICBOOK_DB_HOST and EPICBOOK_DB_PASSWORD first (values are never printed)." >&2
  exit 2
fi

# ---------- Gather: dry run only ----------
# shellcheck disable=SC2086
dry_run_output="$(ANSIBLE_CONFIG="$ansible_dir/ansible.cfg" ANSIBLE_NOCOLOR=1 \
  ansible-playbook -i "$inventory_path" "$playbook_path" --check --diff $extra_args 2>&1)"
dry_run_rc=$?
printf '%s\n' "$dry_run_output" > "$raw_log"
recap="$(grep -E '^[A-Za-z0-9._-]+ +: ok=' <<< "$dry_run_output" || true)"

extract_changed_tasks "$dry_run_output"

# ---------- Analyze ----------
high_count=0
findings=""
for check in "${checks[@]}"; do
  severity="${check%%|*}"
  rest="${check#*|}"
  category="${rest%%|*}"
  pattern="${rest#*|}"
  matches="$(check_tasks_matching_pattern "$pattern")"
  if [[ -n "$matches" ]]; then
    [[ "$severity" == "HIGH" ]] && high_count=$((high_count + 1))
    findings+="[$severity] $category"$'\n'
    while IFS= read -r m; do findings+="    - $m"$'\n'; done <<< "$matches"
  else
    findings+="[OK]   $category: no matching changes"$'\n'
  fi
done

if (( dry_run_rc != 0 )); then
  status="FAILED"; exit_code=2; reason="The dry run itself failed (exit $dry_run_rc). See $raw_log."
elif (( high_count > 0 )); then
  status="FAILED"; exit_code=2; reason="High-risk change pending. Do not apply without a deliberate human review."
elif (( ${#changed_tasks[@]} > 0 )); then
  status="WARNING"; exit_code=1; reason="Changes pending, none high risk. Review the diff before applying."
else
  status="HEALTHY"; exit_code=0; reason="No task would change. The server matches the playbook."
fi

# ---------- Report ----------
{
  echo "Ansible Change Risk Review"
  echo "Reviewer:        $full_name"
  echo "Generated:       $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  echo "Playbook:        $playbook_path"
  echo "Inventory:       $inventory_path"
  echo "Mode:            ansible-playbook --check --diff (dry run, nothing applied)"
  echo "Dry-run exit:    $dry_run_rc"
  echo "Recap:           ${recap:-not available}"
  echo
  echo "Changed tasks (${#changed_tasks[@]}):"
  if (( ${#changed_tasks[@]} == 0 )); then echo "    none"; else printf '    - %s\n' "${changed_tasks[@]}"; fi
  echo
  echo "Risk classification:"
  printf '%s' "$findings"
  echo
  echo "Overall Status:  $status"
  echo "Exit Code:       $exit_code"
  echo "Reason:          $reason"
  echo "Decision:        Nothing was applied. A human decides whether to run the playbook."
} | tee "$report_file"

exit "$exit_code"
