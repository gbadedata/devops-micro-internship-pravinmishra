---
name: k8s-triage
description: Gather read-only Kubernetes evidence for the configured Book Review workload and analyze the report.
allowed-tools: Bash, Read, Grep
disable-model-invocation: true
---

# Kubernetes Incident Triage

When invoked manually through /k8s-triage:
1. Read CLAUDE.md.
2. Run only this Bash command from the workspace root:
   bash scripts/k8s-triage.sh || true
3. Read reports/k8s-health-report.txt. If it is missing or incomplete,
   report evidence gathering failure; never claim the workload is healthy.
4. Summarize overall status and every WARN or FAIL with exact supporting
   evidence and Pod names where available.
5. Identify the most likely cause only when evidence supports it.
6. For HEALTHY, state that no recovery action is required.
7. For WARN without FAIL, explain warnings and suggest read-only investigation
   if useful. Do not recommend a mutation solely because old warnings remain.
8. For FAIL, suggest one evidence-supported recovery command as text for the
   human, using recorded resource names and original image when applicable.
   If evidence is insufficient, suggest one read-only diagnostic instead.
9. Provide one verification command.
10. Never execute a recovery command or any cluster-changing operation.

The script may create its reports directory and overwrite its report.
Do not otherwise create, edit, rename, or delete files.
Do not run apply, delete, edit, patch, scale, set image, rollout restart,
or other mutating Kubernetes operations.
Never reproduce secrets, tokens, credentials, or kubeconfig contents from reports.
These instructions restrict behavior; allowed-tools does not enforce read-only
Kubernetes permissions. The human controls permissions and every recovery action.
