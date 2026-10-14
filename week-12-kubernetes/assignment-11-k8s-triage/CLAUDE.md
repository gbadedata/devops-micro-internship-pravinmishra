# Project: AI-Assisted Kubernetes Incident Triage

## Application configuration
Discovered from the live cluster at 2026-10-14T16:41:52Z; lab-config.md records how.
- Namespace: book-review
- Deployment: backend
- Container: backend
- Pod selector: app=book-review,tier=backend
- Service: backend
- Original working image: gbadedata/book-review-backend:00dd4a5

Keep these values consistent with lab-config.md and scripts/k8s-triage.sh.

## Workflow
Gather → Analyze → Human Act → Verify.

The script collects evidence; Claude analyzes it; the human executes changes.
Use only a personal lab cluster.

## Five health checks
1. Pod status and waiting reasons.
2. Pod readiness.
3. Container restart counts (five or more produces WARN).
4. Namespace Warning events, including historical or unrelated events.
5. Ready Service backends using EndpointSlices, with Endpoints fallback.

## Safety rules
- Never change Kubernetes resources: no apply, delete, patch, edit, scale,
  set image, rollout restart, or other mutating operation.
- Provide recovery commands as text only; the human reviews and executes them.
- Use the Bash report as primary evidence. Do not assert an unsupported cause.
- Missing Pods or failed required queries must not be reported as healthy.
- Logs may be unavailable when a container never started.
- Never display credentials, kubeconfig contents, tokens, or certificates.
- Instructions are not an enforced access boundary. Do not request broad
  permissions or approval for cluster-changing commands.

## Access boundary
- Claude Code runs with the read-only kubeconfig ~/.kube/dmi-week12-triage-readonly: ServiceAccount
  k8s-triage-reader, bound to the built-in view role in book-review plus get on that namespace
  (rbac/k8s-triage-reader.yaml). The API server refuses any change or Secret read made with it.
- .claude/settings.json also denies mutating kubectl subcommands and reads of ~/.kube, ~/.azure
  and ~/.config/dmi. Those rules match command text only; the RBAC binding is the real boundary.
- The human runs incident and recovery commands in a separate terminal with their own credentials.

## Local files and reports
- The supplied script may create reports/ and overwrite k8s-health-report.txt.
- During planning, do not create or edit files.
- During /k8s-triage, do not modify other files.
- Preserve failure and recovery reports through the human's terminal commands.
- Reports include full name, UTC timestamp, configuration, evidence,
  PASS/WARN/FAIL results, overall status, and exit code.
- Exit codes: 0 HEALTHY, 1 WARN, 2 FAIL.
- HEALTHY needs no recovery. WARN needs evidence review, not automatic changes.
- Recovery requires no FAIL; historical warnings may remain.

## Output rules
- Start with the report's Full Name and Timestamp, then the overall status, the PASS, WARN and
  FAIL counts and the exit code.
- List every WARN and FAIL with its exact evidence line and the Pod name.
- Keep observed evidence separate from inference, and say when the evidence is insufficient.
- Give at most one recovery command, as text for the human, and one verification command.
- Never paste tokens, certificates or kubeconfig contents.
