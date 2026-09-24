#!/usr/bin/env bash
# PreToolUse hook: block terraform apply while the latest drift report says FAIL.
# Claude Code sends the pending tool call as JSON on stdin. Exit 2 blocks the call
# and returns stderr to Claude; exit 0 lets it run.

REPORT="${CLAUDE_PROJECT_DIR:-.}/reports/latest-report.txt"
cmd="$(jq -r '.tool_input.command // empty')"

# Only guard commands that invoke terraform apply (including terraform -chdir=... apply)
if ! grep -Eq '(^|[^[:alnum:]_-])terraform([[:space:]]+-[^[:space:]]+)*[[:space:]]+apply([[:space:]]|$)' <<< "$cmd"; then
  exit 0
fi

if [[ ! -f "$REPORT" ]]; then
  echo "BLOCKED by PreToolUse hook: no drift report found at reports/latest-report.txt. Run /tf-drift-review first." >&2
  exit 2
fi

if grep -q '^Overall Status: FAIL' "$REPORT"; then
  echo "BLOCKED by PreToolUse hook: the latest drift report shows 'Overall Status: FAIL'. terraform apply is not allowed until the issue is resolved and a new review is HEALTHY." >&2
  exit 2
fi

exit 0
