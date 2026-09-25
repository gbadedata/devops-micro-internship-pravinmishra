#!/usr/bin/env bash
# PreToolUse hook: Claude Code may only DRY-RUN the playbook.
# Blocks any ansible-playbook command that lacks --check (or -C). Exit 2 blocks the call and
# returns stderr to Claude; exit 0 lets it run. The human applies changes in their own terminal.

cmd="$(jq -r '.tool_input.command // empty')"

# Only guard commands that invoke ansible-playbook
if ! grep -Eq '(^|[^[:alnum:]_-])ansible-playbook([[:space:]]|$)' <<< "$cmd"; then
  exit 0
fi

if grep -Eq '(^|[[:space:]])(--check|-C)([[:space:]]|$)' <<< "$cmd"; then
  exit 0
fi

echo "BLOCKED by PreToolUse hook: ansible-playbook without --check is not allowed from Claude Code. Applying changes is a human decision; give the command to the human instead." >&2
exit 2
