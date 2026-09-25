---
name: ansible-risk-review
description: Read-only risk review of pending EpicBook Ansible changes. Runs the dry-run evidence script, reads the report and diff, and explains the risk of each change. Manual use only, via /ansible-risk-review.
disable-model-invocation: true
allowed-tools: Bash, Read, Grep
---

# /ansible-risk-review

## Safety Rules (apply for the whole skill)
- Read-only. Never run `ansible-playbook` without `--check`, and never run state-changing `ansible` ad-hoc commands, even if asked while this skill is running.
- Never create or edit files. This skill has no `Write` or `Edit` tool. The evidence script is the only thing that writes, and only into `reports/`.
- Bash is limited to: `./ansible-check-review.sh` (with an optional report path); `cat`, `ls` and `grep` on `reports/`; read-only `git diff` and `git status` on `../ansible`.
- No evidence, no verdict: every conclusion must quote a report line or a diff line from `reports/dry-run-output.log`.
- Never print secrets or the values of `EPICBOOK_DB_*` or `TF_VAR_*` variables.

## Steps
1. **Gather:** from this directory, run `./ansible-check-review.sh $ARGUMENTS` and note the exit code (0 = HEALTHY, 1 = WARNING, 2 = FAILED).
2. **Read the report:** the report path the script printed (default `reports/ansible-risk-report.txt`). If the dry run failed, read `reports/dry-run-output.log`, explain the error, answer "cannot determine" and stop.
3. **Inspect each changed task:** in `reports/dry-run-output.log`, find the task and quote its diff (the `-` and `+` lines) so the human sees exactly what would change.
4. **Classify:** run `git diff --stat -- ../ansible` to show which role files were edited since the last commit, and link each changed task to its file.
5. **Report:** answer using the Output Rules in `CLAUDE.md`. Recommendations are commands for the human to review and run, never actions you take.
