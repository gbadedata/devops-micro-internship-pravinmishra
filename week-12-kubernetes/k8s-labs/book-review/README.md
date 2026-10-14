# Book Review App on Kubernetes (DMI Week 12, Assignment 10)

YAML manifests for the three-tier Book Review App on AKS, namespace `book-review`.
Architecture diagram: [a10-03-architecture-diagram.png](../../screenshots/a10-03-architecture-diagram.png)

| File | What it creates |
|---|---|
| `00-namespace.yaml` | Namespace `book-review`, Pod Security `baseline` enforced |
| `01-configmap.yaml` | Non-sensitive backend settings, including `ALLOWED_ORIGINS` (the LoadBalancer IP) |
| `02-secret.example.yaml` | Placeholders only, never applied |
| `03-mysql.yaml` | Headless Service `mysql` and a single-replica MySQL 8.4 StatefulSet with an 8 GiB Azure Disk |
| `04-backend.yaml` | ClusterIP Service `backend` (3001) and the 2-replica Node.js/Express Deployment |
| `05-frontend.yaml` | Nginx config (`/api/` to the backend Service) and the 2-replica Nginx + Next.js Deployment |
| `06-frontend-service.yaml` | The only public entry point: a LoadBalancer Service on port 80 |
| `07-networkpolicies.yaml` | Default-deny ingress plus the three allowed paths |
| `tests/networkpolicy-test.sh` | Checks which tier-to-tier connections the policies allow |
| `tests/pod-hardening-report.py` | Prints probes, resources and security settings per container |

Images: `gbadedata/book-review-backend:00dd4a5` and `gbadedata/book-review-frontend:00dd4a5` on Docker Hub, built from
[gbadedata/book-review-app@00dd4a5](https://github.com/gbadedata/book-review-app/tree/00dd4a53732f8e84ee322059487d29fdaf53f696) (frontend image: [`frontend/Dockerfile.k8s`](https://github.com/gbadedata/book-review-app/blob/00dd4a53732f8e84ee322059487d29fdaf53f696/frontend/Dockerfile.k8s)).

## Deploy order

```bash
kubectl apply -f 00-namespace.yaml
kubectl apply -f 06-frontend-service.yaml   # first, so its public IP can go into ALLOWED_ORIGINS
# put http://<EXTERNAL-IP> in ALLOWED_ORIGINS in 01-configmap.yaml, then:
kubectl apply -f 01-configmap.yaml
kubectl create secret generic book-review-secrets -n book-review --from-env-file=<local file, never committed>
kubectl apply -f 03-mysql.yaml
sed 's/^  replicas: 2$/  replicas: 1/' 04-backend.yaml | kubectl apply -f -   # one Pod creates the schema and sample data
kubectl apply -f 04-backend.yaml            # then scale to 2
kubectl apply -f 05-frontend.yaml
kubectl apply -f 07-networkpolicies.yaml
```

The local Secret file holds `MYSQL_ROOT_PASSWORD`, `DB_PASS` and `JWT_SECRET`; see `02-secret.example.yaml` for the keys.
