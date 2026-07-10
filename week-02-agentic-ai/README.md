# Week 02 - Agentic AI with Claude Code

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Overview

Week 2 is where this internship stops talking about AI and starts building with it. Across 8 assignments I build the complete `.claude/` operating system on top of the course portfolio site: installing and running Claude Code, teaching it the project through CLAUDE.md, turning repeatable infrastructure workflows into reusable skills, delegating specialised work to subagents, connecting Claude to live external tools through MCP, wrapping everything in safety hooks and permissions, giving it memory that survives across sessions, and finishing with a written reflection on how the workflow changed the way I work.

The point is not to let AI run wild on infrastructure. It is the opposite: keep a human in control while the AI handles the boilerplate, with guardrails that make that safe.

**Working repository (where the `.claude/` system is built):** https://github.com/gbadedata/Ultimate-Agentic-DevOps-with-Claude-Code

**Environment for the whole week:** Ubuntu 24.04 on WSL2, VS Code connected through the Microsoft WSL extension, Claude Code v2.1.206 running on native Linux Node (installed with nvm), authenticated with a Claude Max subscription.

| # | Assignment | Focus | Status |
|---|-----------|-------|--------|
| 1 | Setup & Agentic Loop | Install Claude Code, observe Gather, Act, Verify | Done |
| 2 | CLAUDE.md | Teach Claude the project | Done |
| 3 | Skills | Reusable slash-command workflows | Done |
| 4 | Subagents | A team of specialist agents | Pending |
| 5 | MCP | Connect Claude to live tools | Pending |
| 6 | Hooks & Permissions | Safety guardrails | Pending |
| 7 | Memory | Persistence across sessions | Pending |
| 8 | Reflection Blog | Write up the week | Pending |

---

## Assignment 1: Setup & Agentic Loop

**Goal:** Install and authenticate Claude Code, fork and clone the starter repository, and watch how the Agentic Loop (Gather, Act, Verify) works before any configuration is in place.

### What I did

1. **Installed and authenticated Claude Code.** Installed the CLI with `npm install -g @anthropic-ai/claude-code` and signed in with my Claude Max subscription. Running version: 2.1.206.

2. **Forked and cloned the starter repo** into `~/DMI` and opened it in VS Code. To make the assignment work as intended, I reset my fork back to the bare starter, removing the `CLAUDE.md`, `.claude/`, and GitHub Actions workflow that the repo now ships with, so I could build the `.claude/` system from scratch across the coming assignments. The bare state is just `index.html`, `style.css`, `privacy.html`, `terms.html`, `README.md`, and `images/`, with no `.claude/` and no `CLAUDE.md`.

3. **Fixed the environment properly.** Claude Code was initially resolving to a Windows Node install that leaked into WSL through a shared PATH. That showed up as Windows-style paths (`\\wsl.localhost\...`) and file ownership that did not match Linux. I installed native Linux Node with nvm and reinstalled Claude Code on it, so `which claude` now resolves to a path under `~/.nvm/...` and everything runs in the Linux environment the later assignments expect.

4. **Observed the Agentic Loop** on two safe questions:
   - *"What files are in this project and what does each one do?"* Claude read the files first (the Gather phase, visible as Read tool calls) before describing each one. It correctly identified the project as a static portfolio site with no JavaScript and no build step.
   - *"How many lines of CSS does this project have?"* Claude ran a shell command, `wc -l style.css` (the Act phase), and reported the result.

### Key finding

`style.css` has **1,145 lines**. The two legal pages (`privacy.html` and `terms.html`) carry another 87 lines each of inline styles, for 1,319 lines of CSS total across the project. The value of the exercise was watching Claude read the files and run a command to reach that number rather than guessing it.

### What I learned

Claude Code is a CLI tool, so it runs in any terminal, but on WSL it is easy to accidentally run the Windows build against your Linux files. Getting Node and Claude Code installed natively inside Ubuntu, and confirming it with `which claude`, is the setup step that prevents a whole class of path and permission problems later. Watching the loop on low-stakes questions first is how you build trust in the tool before handing it real infrastructure.

### Screenshots

**1. Claude Code installed (`claude --version`)**

![Claude Code version](./screenshots/a1-1-claude-version.png)

**2. Authenticated (Claude Max)**

![Claude Code auth banner](./screenshots/a1-2-auth-banner.png)

**3. Bare starter file tree (no `.claude/`, no `CLAUDE.md`)**

![Bare file tree](./screenshots/a1-3-bare-file-tree.png)

**4. Gather phase: Claude reads the files before answering**

![File map](./screenshots/a1-4-file-map.png)

**5. Act phase: Claude runs a command and reports the CSS line count**

![CSS line count](./screenshots/a1-5-css-count.png)

---

## Assignment 2: CLAUDE.md

**Goal:** Generate a starter CLAUDE.md, customize it into five sections, and prove through a before/after test that Claude's behaviour changes based on the file.

### What I did

1. **Captured the "before" state.** With no CLAUDE.md in the project, I asked Claude "What is this project and how should I deploy it?" It read the files and gave a generic answer: deploy with Nginx on an Ubuntu VM. It had no idea about the intended AWS deployment because nothing had told it.

2. **Generated a first draft with `/init`.** Claude scanned the project and wrote a starter CLAUDE.md. It captured the static site, the two separate CSS systems, and the DMI footer rule, but said nothing about S3, CloudFront, or Terraform.

3. **Customized it into five sections:** Project Overview (S3, CloudFront, Terraform, GitHub Actions), Architecture (with the explicit "Pure HTML5 and CSS3. No JavaScript." line), Commands (terraform init, plan, apply, and a local preview), Conventions (Terraform-only changes, no JavaScript, mobile-first breakpoints), and Safety (no secrets in the file). I deliberately wrote "No JavaScript" as a flat rule rather than framing the missing script as a bug to fix, so the convention would actually hold in the next test.

4. **Proved the file changed Claude's behaviour** in a fresh session (a fresh session is required because Claude only reads CLAUDE.md at startup):
   - Same deployment question, different answer. This time Claude described the project as AWS S3 and CloudFront provisioned with Terraform and automated via GitHub Actions, pulled straight from CLAUDE.md, and even flagged that the Terraform does not physically exist in the repo yet.
   - Asked to "Add a React component to the homepage," Claude refused and cited CLAUDE.md by name, quoting both the Architecture line ("Pure HTML5 and CSS3. No JavaScript.") and the Conventions line ("No JavaScript in this project."), then asked me to confirm before doing anything.

### What I learned

README.md is written for humans; CLAUDE.md is written for the AI. The same question produced a completely different answer once the file existed, which is the clearest possible proof that a few lines of project context change how the agent behaves across every session. Writing conventions as firm rules, not soft observations, is what makes the agent enforce them.

### Screenshots

**1. Before: no CLAUDE.md, generic Nginx deployment answer**

![Before, no CLAUDE.md](./screenshots/a2-1-before-nginx.png)

**2. Auto-generated CLAUDE.md from /init**

![Auto-generated CLAUDE.md](./screenshots/a2-2-init-generated.png)

**3. Customized CLAUDE.md with all five sections**

![Customized CLAUDE.md](./screenshots/a2-3-customized-claude-md.png)

**4. After: CLAUDE.md loaded, AWS-aware deployment answer**

![After, AWS deployment answer](./screenshots/a2-4-after-aws.png)

**5. Claude refuses to add React, citing the No JavaScript convention**

![React refused](./screenshots/a2-5-react-refused.png)

---

## Assignment 3: Skills

**Goal:** Build the `.claude/skills/` folder with four skills, understand why each one has a different set of tool permissions, and run `/scaffold-terraform` to generate a full Terraform setup from a single command.

### What I did

1. **Created four skills** under `.claude/skills/`, each in its own folder with a `SKILL.md` file: `scaffold-terraform` (generate Terraform), `tf-plan` (plan and analyze), `tf-apply` (apply after review), and `deploy` (sync to S3 and invalidate CloudFront). The `scaffold-terraform` skill also carries a `template-spec.md` that defines the infrastructure to generate.

2. **Confirmed the least-privilege design.** The key detail is that each skill only gets the tools its job needs. `tf-plan` has `allowed-tools: Bash, Read, Grep` and no Write, because a plan should never modify anything. `scaffold-terraform` is the only skill with Write, because generating files is its whole purpose. All action skills also set `disable-model-invocation: true`, so they run only when I invoke them, never automatically.

3. **Ran `/scaffold-terraform`.** From one command, Claude read the template spec and generated five clean Terraform files in a new `terraform/` folder: `providers.tf`, `variables.tf`, `main.tf`, `outputs.tf`, and `backend.tf`. The generated infrastructure is a private S3 bucket with public access blocked, a scoped bucket policy, a modern Origin Access Control (not legacy OAI), and a CloudFront distribution with HTTPS redirect, a 404 to index.html rewrite, PriceClass_200, and the managed CachingOptimized policy. The backend is commented out with bootstrap instructions for the first run.

4. **Ran `terraform init` and `/tf-plan`.** After `terraform init` pulled the AWS provider, the `/tf-plan` skill ran a plan that validated cleanly (6 to add, 0 to change, 0 to destroy) and, more usefully, produced a risk analysis around it: a resource table, notes on S3 bucket-name global uniqueness and CloudFront deploy time, the default-certificate caveat, and a blast-radius summary. I stopped at the plan and did not run `apply`, since provisioning live infrastructure belongs to a later week.

### What I learned

The interesting part of this assignment was not the automation, it was the constraint underneath it. Least privilege, the same rule we apply to IAM roles and service accounts, applies just as well to an AI agent: give each skill the smallest set of tools that lets it do its job, and make anything that touches infrastructure manual-only. A skill with no Write tool physically cannot leave a change behind. That is what makes handing repeatable workflows to an agent safe, with a human still reviewing the plan before anything ships. I wrote this up in full detail on my blog (linked below).

### Screenshots

**1. The `.claude/skills/` folder with all four skills**

![Skills folders](./screenshots/a3-1-skills-folders.png)

**2. The `scaffold-terraform` skill folder (SKILL.md and template-spec.md)**

![Scaffold skill files](./screenshots/a3-2-scaffold-files.png)

**3. `tf-plan/SKILL.md` frontmatter: Bash, Read, Grep, and no Write (least privilege)**

![tf-plan frontmatter](./screenshots/a3-3-tf-plan-frontmatter.png)

**4. Running `/scaffold-terraform`: Claude generates the Terraform files**

![Scaffold run](./screenshots/a3-4-scaffold-run.png)

**5. The generated `terraform/` folder with all five .tf files**

![Terraform folder](./screenshots/a3-5-terraform-folder.png)

**6. Running `/tf-plan`: clean plan plus risk analysis**

![tf-plan run](./screenshots/a3-6-tf-plan-run.png)

### Write-up

Full article: [One Command Wrote My Entire AWS Infrastructure. The Interesting Part Is What It Wasn't Allowed to Do.](https://gbadedata.hashnode.dev/agentic-devops-skills-claude-code)

---

## Assignment 4: Subagents

*In progress.*

---

## Assignment 5: MCP

*In progress.*

---

## Assignment 6: Hooks & Permissions

*In progress.*

---

## Assignment 7: Memory

*In progress.*

---

## Assignment 8: Week 2 Reflection Blog

*In progress.*

---

## Public Write-ups

Week 2 asks for public posts on Assignment 3 (Skills), Assignment 7 (Memory), and the Assignment 8 reflection. Links added as published.

- Assignment 3 (Skills): [Hashnode article](https://gbadedata.hashnode.dev/agentic-devops-skills-claude-code)
- Assignment 7 (Memory):
- Reflection:

---

*Part of the [DevOps Micro Internship with Agentic AI](https://www.linkedin.com/in/pravin-mishra-aws-trainer/) by Pravin Mishra. Join: https://discord.pravinmishra.com/*
