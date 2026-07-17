---
name: linux-triage
description: Gather and analyse Nginx health evidence on this server. Runs the read-only triage script, reads the report, and explains what the evidence shows. Suggests a recovery command for the human to run. Never executes recovery.
allowed-tools: Bash, Read, Grep
disable-model-invocation: true
---

# /linux-triage

Runs the GATHER and ANALYSE phases of the incident workflow in CLAUDE.md.
The human runs recovery. This skill does not.

## What to do

1. Run `./scripts/linux-triage.sh` from the project root. Capture its full output
   and its exit code.
2. Read the newest file in `reports/` to confirm what was written.
3. Report every check's verdict exactly as the script produced it. Do not
   re-interpret a PASS as a FAIL or vice versa.
4. If anything is not PASS: name the most likely cause and quote the specific
   evidence lines that support it. If the evidence supports more than one cause,
   say so rather than picking one.
5. End with exactly one suggested recovery command in a code block, labelled
   FOR THE HUMAN TO RUN.
6. Note the disk usage on / as context if it is above 85 percent, flagged as an
   observation rather than one of the five graded checks.

## Hard limits

- This skill has Bash, Read and Grep. It does NOT have Write or Edit, so it
  cannot create or modify a file even if asked.
- Do NOT run any recovery command. Not systemctl start, restart, reload, not a
  file restore, not anything that changes state. Suggest it as text only.
- Do NOT claim the service has recovered. Only a second triage run, after the
  human has acted, can establish that.
- Do NOT diagnose without citing a line from the report.
