# Incident Summary: backend rollout stuck on an image that does not exist

Oluwagbade Odimayo, DMI Week 12, Assignment 11, 14 October 2026 (times in UTC).
Workload: Deployment `backend` (container `backend`), namespace `book-review`, AKS cluster `aks-oluwagbade-week12`.

## 1. Reported Symptom

At about 17:30 a new rollout of `backend` stopped making progress. The new Pod `backend-645fcc9476-r92gc` stayed at
READY 0/1 in `ErrImagePull`, then `ImagePullBackOff`, and `kubectl rollout status` timed out at "1 out of 2 new
replicas have been updated". The API kept answering, because both existing Pods were still running.

## 2. Evidence Collected

`scripts/k8s-triage.sh`, run with the read-only identity, saved as `reports/incident-failure-report.txt`
(17:32:25, overall FAIL, exit code 2):

- `[FAIL] One or more pods are in a bad state: backend-645fcc9476-r92gc ImagePullBackOff`
- `[FAIL] Pod(s) not passing readiness: backend-645fcc9476-r92gc (READY 0/1)`
- `[WARN]` Warning events, all for that Pod and 11 to 34 seconds old: `Failed to pull image
  "gbadedata/book-review-backend:0.0.0-does-not-exist": ... not found`, `Error: ErrImagePull`, `Error: ImagePullBackOff`
- `[PASS]` Service `backend`: EndpointSlice `backend-zr6n9` listed the two old Pods `ready=true` and the new Pod `ready=false`
- `[PASS]` no Pod with 5 or more restarts; no previous-container logs, because the container never started

Kubernetes at the same time (Screenshot 13): both `backend-7f95954f96` Pods 1/1 Running, the new Pod 0/1, the rollout timed out.

## 3. Most Likely Cause

The Deployment's Pod template was changed to the image tag `0.0.0-does-not-exist`, which Docker Hub reports as not
found, so the container could never start. The events name the exact image and the NotFound error, so the evidence
supports this cause directly. It was the drill's deliberate change, made with `kubectl set image` from my own terminal.

## 4. Human-Approved Recovery Action

Claude suggested one command, as text, using the original image recorded in CLAUDE.md and lab-config.md. I checked it
against the recorded image and ran it myself, in my own terminal, with my own credentials:

```bash
kubectl -n book-review set image deployment/backend backend=gbadedata/book-review-backend:00dd4a5
kubectl rollout status deployment/backend -n book-review --timeout=180s
```

The template matched the old ReplicaSet `7f95954f96` again, so Kubernetes scaled the broken ReplicaSet `645fcc9476`
to 0 and deleted its Pod. The two healthy Pods were never restarted.

## 5. Verification

- Kubernetes (Screenshot 16): image `gbadedata/book-review-backend:00dd4a5`, ReplicaSet `645fcc9476` at 0,
  `7f95954f96` at 2/2, both Pods 1/1 Running with 0 restarts, EndpointSlice both `ready=true`. Deployment
  generation 6 (4 before the drill), rollout history revision 5.
- Second triage run, `reports/recovery-report.txt` (17:46:18): PASS 5, WARN 1, FAIL 0, exit code 1.
- The one WARN is historical: its Warning events belong to the deleted Pod `backend-645fcc9476-r92gc` and were 13
  minutes and 5m45s old, older than the scale-down (78s). They expired after about an hour, and a later
  `kubectl get events -n book-review --field-selector type=Warning` returned "No resources found".

## 6. Safety Decision

Claude only gathered evidence and analysed it; every change was mine.

- Enforced: Claude Code ran with a kubeconfig for the ServiceAccount `k8s-triage-reader`, bound to the built-in `view`
  role in `book-review` plus get on the namespace (`rbac/k8s-triage-reader.yaml`). It cannot change anything or read
  Secrets; `reports/readonly-identity-check.txt` shows the permission checks and a write attempt refused as Forbidden.
- Secondary: `.claude/settings.json` denies mutating kubectl subcommands and reads of `~/.kube`, `~/.azure` and
  `~/.config/dmi`. These rules only match command text, so they are not the boundary.
- Process: the planning step ran in plan mode, and I typed the drill and the recovery in a separate terminal.
- Audit: Claude Code's own session transcripts list everything it ran: two file reads while planning, the triage script
  three times, and `cat`, `tail` and `grep` on the report file. Those three go beyond the skill's "run only this
  command", but they only read the local report. Claude never ran a cluster-changing command.

## 7. Agentic Loop Mapping

| Phase | Who | What happened | Evidence |
|---|---|---|---|
| Gather | `scripts/k8s-triage.sh` with the read-only identity | Preflight, five checks and log capture, written to the report with an exit code | `reports/incident-failure-report.txt` |
| Analyze | Claude Code via `/k8s-triage` | Tied both FAILs to the not-found tag, noted the old Pods kept serving, suggested one recovery and one verification command | Screenshot 14 |
| Human Act | Me, in my own terminal | Reviewed the suggestion, set the image back to `00dd4a5`, waited for the rollout | Screenshot 16 |
| Verify | The script again, then Claude | No FAIL; the remaining WARN traced to the deleted Pod's old events | `reports/recovery-report.txt`, Screenshot 17 |
