# Lab configuration (DMI Week 12, Assignment 11)

Recorded from the live cluster at 2026-10-14T16:41:52Z, before any incident simulation. CLAUDE.md and
scripts/k8s-triage.sh use the same values.

| Setting | Value | How it was discovered |
|---|---|---|
| Full name | Oluwagbade Odimayo | |
| Platform | Azure Kubernetes Service, Kubernetes v1.35.8, UK West | `kubectl get nodes` |
| Human kubectl context | aks-oluwagbade-week12 (personal lab cluster) | `kubectl config current-context` |
| Namespace | book-review | Book Review App namespace from Assignment 10 |
| Deployment | backend: 2 replicas, RollingUpdate with maxSurge 1 and maxUnavailable 0 | `kubectl get deploy backend -n book-review -o json` |
| Container | backend (init container wait-for-mysql uses the same image) | `.spec.template.spec.containers` |
| Pod selector | app=book-review,tier=backend | `.spec.selector.matchLabels` |
| Service | backend: ClusterIP, port 3001 | the only Service whose selector matches the Pod labels |
| Readiness probe | HTTP GET / on port http (3001) | `.spec.template.spec.containers[].readinessProbe` |
| Original working image | gbadedata/book-review-backend:00dd4a5 | `.spec.template.spec.containers[].image` |
| Original image digest | docker.io/gbadedata/book-review-backend@sha256:92e6c11770303cf2fb96fb77d44f68a245bb966459b0facac314ec78d75facfd | `.status.containerStatuses[].imageID` of the running Pods |
| Ready Service backends at discovery | 2 | EndpointSlices labelled `kubernetes.io/service-name=backend` |
| Claude Code's cluster identity | ServiceAccount k8s-triage-reader, read-only (`view` in book-review plus get on the namespace) | [`rbac/k8s-triage-reader.yaml`](rbac/k8s-triage-reader.yaml) |
| Claude Code's kubeconfig | ~/.kube/dmi-week12-triage-readonly, mode 600, never committed | created from a short-lived token |
