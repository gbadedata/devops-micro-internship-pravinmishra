# Book Review Terraform Capstone — Claude Code Project Instructions

## Role
Act as an AI DevOps engineering assistant for the Book Review App Terraform capstone. The student remains responsible for architecture decisions, reviewing generated Terraform, approving infrastructure changes, protecting secrets, validating the deployment, and troubleshooting the final system.

Do not treat AI-generated infrastructure as automatically correct.

## Application
Repository: https://github.com/pravinmishraaws/book-review-app

- Frontend: Next.js
- Backend: Node.js / Express
- Database: MySQL

Before creating deployment automation, inspect the repository and its package files. Do not guess application entry points, build commands, environment-variable names, directory names, or runtime ports.

## Required Architecture
Build a production-style three-tier architecture using Terraform on the cloud selected by the student.

Network:
- Custom network CIDR: 10.0.0.0/16
- Two public Web Tier subnets
- Two private Application Tier subnets
- Two private Database Tier subnets
- Spread across two availability locations where supported

Example AWS subnet plan:
- Web A: 10.0.1.0/24
- Web B: 10.0.2.0/24
- App A: 10.0.11.0/24
- App B: 10.0.12.0/24
- DB A: 10.0.21.0/24
- DB B: 10.0.22.0/24

Traffic flow:
Internet -> Public Load Balancer -> Web Tier -> Internal Load Balancer -> Application Tier -> Managed MySQL

Backend:
- Runs on port 3001
- Must not be publicly accessible

Database:
- MySQL port 3306
- Must not be publicly accessible
- Must accept MySQL traffic only from the Application Tier
- Use private networking
- Configure high availability / Multi-AZ equivalent
- Configure a read replica where required

## Terraform Engineering Rules
- Use modular Terraform.
- Prefer logical modules such as network, security, load-balancer, compute, and database.
- Use variables for configurable values.
- Use outputs only for values that genuinely need to be exposed.
- Pass dependencies between modules using module inputs and outputs.
- Use consistent naming and tags where supported.
- Do not hard-code cloud credentials.
- Do not output passwords, private keys, tokens, or other secrets.
- Do not commit Terraform state files.
- Do not assume provider arguments from memory when current documentation can be consulted.
- Use the Terraform MCP server for current Terraform Registry/provider/module information when relevant.
- Explain important architecture or security decisions before making significant changes.

## Required Engineering Sequence
Work incrementally. Do not generate the entire project in one uncontrolled step.

1. Networking
2. Security
3. Load Balancing
4. Database
5. Compute
6. Application Deployment
7. Verification and Troubleshooting

## Validation Workflow
Before deployment:
1. terraform fmt
2. terraform validate
3. terraform plan
4. Review for unexpected public IPs, 0.0.0.0/0 rules, public DB exposure, incorrect 3001/3306 exposure, deletions/replacements, missing resources, and obvious cost risks.
5. Request architecture/security review where appropriate.
6. Require human approval before terraform apply.

## Safety Rules
- Never automatically approve terraform apply.
- Never automatically execute terraform destroy.
- Never weaken network security merely to make the application work.
- Never expose credentials or secrets in output, screenshots, logs, Terraform outputs, or committed files.
- Never copy private SSH keys into source control.
- Prefer diagnosing root cause before changing infrastructure.
- Make one controlled change at a time and retest.
- If a Terraform resource or argument is uncertain, consult current documentation rather than guessing.

## Troubleshooting Method
When a deployment fails:
1. Observe the failure.
2. Collect evidence.
3. Identify the likely failing layer.
4. Propose diagnostic checks in order.
5. Verify the root cause.
6. Make one controlled fix.
7. Retest.

Useful evidence includes Terraform errors/plans, route tables, security rules, target health, curl results, Nginx logs, application logs, PM2 logs, DNS results, and DB connection errors.

## Subagents
Use `terraform-engineer` for Terraform implementation, documentation-backed Terraform decisions, module creation, validation, and plan analysis.

Use `architecture-security-reviewer` after major phases and before deployment to independently review architecture, networking, security, availability, secrets, and Terraform quality.

Reviewer findings must be evaluated before changes are made.

## Project Specifics (Oluwagbade Odimayo)
Facts below were verified in the application repository. Use them instead of guessing.

### Environment
- Cloud: AWS, region eu-west-2 (London). Terraform root: `terraform/`, modules under `terraform/modules/`.
- The AWS provider pins the account with `allowed_account_ids`; the value lives in the git-ignored `terraform/local.auto.tfvars`, together with the owner's SSH CIDR.
- Secrets (DB password, JWT secret) come only from `TF_VAR_db_password` and `TF_VAR_jwt_secret`, are marked `sensitive`, and reach instances through SSM Parameter Store SecureString read by an instance IAM role. Never put secrets in tfvars, outputs, user data or git.
- Use Ubuntu 24.04 LTS AMIs: its Node.js 18.19 meets Next.js 15's minimum (Ubuntu 22.04 ships Node 12, which fails).

### Application facts
- Frontend: Next.js 15 in `frontend/`. Build with `npm ci && npm run build`, serve with `npm start` on port 3000.
- `NEXT_PUBLIC_API_URL` is baked in at build time and used by browser-side code. Set it to `/api` (relative): the browser calls the public load balancer, and Web Tier Nginx proxies `/api/` to the internal load balancer. Backend routes are mounted under `/api/...`, so the value must include `/api` despite the code comment in `frontend/src/services/api.js`.
- `frontend/src/app/page.js` appends `/api` itself (`${NEXT_PUBLIC_API_URL}/api/books`), unlike `api.js`, so the homepage requests `/api/api/books`; the Web Tier Nginx collapses `/api/api/` with a server-level `rewrite ^/api(/api/.*)$ $1 last;` (inside `location /api/` it fails). Do not change `NEXT_PUBLIC_API_URL` to work around it.
- Backend: Express in `backend/`, started with `node src/server.js`. Environment: `PORT=3001`, `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASS`, `JWT_SECRET`, `ALLOWED_ORIGINS`. The committed `backend/.env` holds placeholder secrets and must be replaced on the server.
- Backend CORS rejects unknown origins: `ALLOWED_ORIGINS` must include `http://<public load balancer DNS>`.
- Backend connects to MySQL with SSL required (`dialectOptions.ssl` in `backend/src/config/db.js`). Keep it.
- Backend creates its tables and seeds sample data on first start; only the database named in `DB_NAME` must already exist.
- Health checks: Web Tier target `GET /` on port 80; Application Tier target `GET /` on port 3001 (returns 200 with a text banner).

### Agreed cost decisions (documented trade-offs)
- One NAT gateway in Web subnet A for private-tier outbound traffic (saves cost; accepted single point of failure for outbound only).
- Web Tier `t3.small` (Next.js build needs about 2 GB RAM); Application Tier `t3.micro`; database `db.t3.micro` Multi-AZ plus one `db.t3.micro` read replica.
- Destroy promptly after evidence is captured.
