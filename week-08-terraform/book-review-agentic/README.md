# Book Review Capstone — Claude Code Agentic Starter Pack

This pack gives students a consistent, safety-oriented Claude Code workflow for the Book Review Terraform capstone.

## Included
- `CLAUDE.md` — persistent project requirements and safety rules
- `.mcp.json` — project-scoped HashiCorp Terraform MCP server
- `.claude/agents/terraform-engineer.md` — Terraform implementation subagent
- `.claude/agents/architecture-security-reviewer.md` — read-only review subagent
- `.claude/settings.json` — human approval rules plus Terraform formatting hook
- `terraform/` — working directory for Terraform code

## Prerequisites
- Claude Code installed and authenticated
- Terraform CLI installed
- Docker installed and running
- AWS CLI or Azure CLI for the selected cloud
- Access to the Book Review application repository

The Terraform MCP server uses HashiCorp's official Docker image. Public Terraform Registry information does not require an HCP Terraform token. `ENABLE_TF_OPERATIONS=false` keeps Terraform MCP infrastructure-operation capabilities disabled.

## First-Time Setup
1. Extract the pack.
2. Open a terminal in the project root.
3. Run `claude`.
4. Inspect and then accept workspace trust.
5. In Claude Code run `/mcp` and approve the project `terraform` MCP server.
6. From a terminal, you can also run `claude mcp list`.
7. Confirm Terraform with `terraform version`.
8. Put Terraform configuration under `terraform/`.

## Recommended Workflow
1. Analyze requirements.
2. Ask Claude for an architecture plan.
3. Review it.
4. Use `terraform-engineer` to implement one phase.
5. Validate the phase.
6. Use `architecture-security-reviewer` after major phases.
7. Run and review `terraform plan`.
8. Human approves `terraform apply`.
9. Test the application.
10. Troubleshoot from evidence.
11. Run a final architecture/security review.
12. Human controls `terraform destroy`.

Example prompt:

`Use the terraform-engineer subagent to design Phase 1 networking for AWS. First inspect CLAUDE.md, then propose the module design and subnet/AZ plan. Use Terraform MCP for current AWS provider documentation. Explain the plan before implementing it.`

Example review prompt:

`Use the architecture-security-reviewer to review the networking and security Terraform against CLAUDE.md. Report PASS, WARN, and FAIL findings. Do not modify files.`

## Hook Behavior
After Claude successfully uses Edit or Write, the project hook runs:

`terraform fmt -recursive`

Validation is intentionally not triggered after every single edit because partially built modules can be temporarily invalid and `terraform validate` normally becomes meaningful after `terraform init`. Run validation at logical checkpoints.

## Why No Skills?
Skills are not required in this starter version. Persistent context, specialized subagents, Terraform MCP, and hooks already provide the core learning workflow. Skills can be introduced later for repeated reusable workflows.

## Security Notes
- Never commit `.env`, private keys, Terraform state, credentials, or secrets.
- Claude Read access is denied for common `.env`, key, and Terraform-state patterns.
- Never paste secrets into prompts.
- Never approve infrastructure-changing commands without understanding them.
- Do not weaken Security Groups/NSGs merely to make connectivity work.

## MCP Troubleshooting
1. `docker version`
2. `docker pull hashicorp/terraform-mcp-server`
3. `claude mcp list`
4. Inside Claude Code: `/mcp`
5. Review pending project-server approval.
