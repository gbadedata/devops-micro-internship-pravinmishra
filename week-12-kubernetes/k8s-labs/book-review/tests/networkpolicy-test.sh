#!/usr/bin/env bash
# NetworkPolicy access test for the book-review namespace (DMI Week 12, Assignment 10).
# Opens plain TCP connections from a Pod in each tier, and from a test Pod with no tier label,
# and reports which connections the policies allow. Nothing is changed; the test Pod deletes itself.
set -euo pipefail
NS=book-review
PROBE='const net = require("net");
const probe = (target) => new Promise((done) => {
  const [host, port] = target.split(":");
  const s = net.connect({ host, port: Number(port), timeout: 5000 });
  s.on("connect", () => { s.destroy(); done("ALLOWED"); });
  s.on("timeout", () => { s.destroy(); done("BLOCKED (no answer in 5s)"); });
  s.on("error", (e) => done("ERROR " + e.code));
});
(async () => { for (const t of process.argv.slice(1)) console.log(`  ${t} -> ${await probe(t)}`); })();'
IMAGE=$(kubectl get deploy backend -n $NS -o jsonpath='{.spec.template.spec.containers[0].image}')

echo "--- NetworkPolicies in $NS"
kubectl get networkpolicy -n $NS
echo "--- from a frontend Pod (tier=frontend): backend should be allowed, mysql blocked"
kubectl exec deploy/frontend -n $NS -c nextjs -- node -e "$PROBE" backend:3001 mysql:3306
echo "--- from a backend Pod (tier=backend): mysql should be allowed"
kubectl exec deploy/backend -n $NS -c backend -- node -e "$PROBE" mysql:3306
echo "--- from a test Pod with no tier label: both should be blocked"
kubectl run np-test -n $NS --image=$IMAGE --restart=Never --rm -i --quiet --command -- node -e "$PROBE" backend:3001 mysql:3306
