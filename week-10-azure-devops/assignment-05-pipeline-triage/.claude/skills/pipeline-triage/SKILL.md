---
name: pipeline-triage
description: Run the read-only EpicBook dual-pipeline triage script, analyze the evidence, and produce a concise diagnosis with one recommended fix for a human to review. Never edits files, never re-runs, cancels, or approves a pipeline, and never touches secrets or service connections.
disable-model-invocation: true
allowed-tools:
  - Bash(./pipeline-triage.sh)
  - Read
  - Grep
disallowed-tools:
  - Edit
  - Write
  - NotebookEdit
---

# Pipeline Triage Skill

When `/pipeline-triage` is invoked:

1. Read `CLAUDE.md` before doing anything else, and follow its Safety Rules and Output Rules.
2. Run exactly `./pipeline-triage.sh` from the assignment root. Do not add arguments, pipes, or redirections, and do not run any other command.
3. Read `reports/pipeline-health-report.txt`. If a pipeline failed, read the matching sanitized raw log (`reports/infra-last-run.log` or `reports/app-last-run.log`) to confirm the evidence. Use only Read and Grep for this.
4. Report the following, in this order:
   - Overall pipeline health, and the `Script Exit Code` line from the report
   - Affected pipeline
   - Pipeline run ID
   - Every WARN, FAIL, or ERROR result
   - The most likely failure category: dependency installation, build or compilation, test, authentication/authorization/SSH, agent availability/timeout/queue, Terraform infrastructure, Ansible/Nginx/deployment, or unclassified
   - The exact sanitized evidence supporting it (quote the matching line from the report or log)
   - One likely root-cause explanation supported by that evidence. If the evidence is incomplete, say the root cause is not confirmed.
   - One specific recovery recommendation for the human to review and apply (e.g. "remove the invalid dependency from package.json", "re-authorize the secure file for this pipeline")
   - One verification step the human can use after applying the fix
5. If every check passes, clearly state that both pipelines are healthy and no fix is required.
6. Do not edit, create, or delete any file, including pipeline YAML and the reports.
7. Do not trigger, retry, cancel, delete, or approve a pipeline run, and do not run Terraform, Ansible, Azure CLI, curl, or git commands.
8. Do not read, print, or reference the value of any secret, token, authorization header, SSH key, database credential, or service connection credential. Only note that one may be wrong, expired, or missing based on log evidence. Never ask for a secret to be pasted into the session.
9. Ask the human to review and apply any recommended fix manually, then re-run `/pipeline-triage` to verify.
