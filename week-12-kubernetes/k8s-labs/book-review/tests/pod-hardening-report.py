# Probe, resource and security settings of every container in the book-review namespace (DMI Week 12, Assignment 10).
# Usage: kubectl get pods -n book-review -o json | python3 tests/pod-hardening-report.py
import json
import sys


def probe(p):
    if not p:
        return "-"
    if "httpGet" in p:
        return f"GET {p['httpGet']['path']}"
    if "exec" in p:
        return "exec mysqladmin ping"
    if "tcpSocket" in p:
        return "tcp"
    return "?"


rows = []
for pod in json.load(sys.stdin)["items"]:
    pod_sc = pod["spec"].get("securityContext", {})
    for c in pod["spec"]["containers"]:
        sc, res = c.get("securityContext", {}), c.get("resources", {})
        req = res.get("requests", {})
        rows.append((
            pod["metadata"]["name"], c["name"],
            probe(c.get("startupProbe")), probe(c.get("readinessProbe")), probe(c.get("livenessProbe")),
            f"{req.get('cpu', '-')}/{req.get('memory', '-')}", res.get("limits", {}).get("memory", "-"),
            str(sc.get("runAsUser", pod_sc.get("runAsUser", "image default"))),
            "yes" if sc.get("readOnlyRootFilesystem") else "no",
            "yes" if sc.get("allowPrivilegeEscalation") is False else "no",
        ))
hdr = ("POD", "CONTAINER", "STARTUP", "READINESS", "LIVENESS", "REQ CPU/MEM", "MEM LIMIT", "UID", "RO ROOT", "NO PRIV ESC")
w = [max(len(r[i]) for r in rows + [hdr]) for i in range(len(hdr))]
for r in [hdr] + rows:
    print("  ".join(v.ljust(w[i]) for i, v in enumerate(r)).rstrip())
