# Assignment 4 — Building Your AI Team

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will build and configure a set of specialized AI subagents inside your project. You will learn how different models and tool permissions define agent behavior, and you will trigger two real agent delegations to analyze security and cost aspects of your Terraform infrastructure.

---

# Task 1 — Create the Agents Folder and Add Files

## Goal

Create the `.claude/agents/` directory and add all required agent files.

### Evidence

#### Screenshot 1 — VS Code sidebar showing `.claude/agents/` with all 3 files

![Screenshot 1](./screenshots/a4-1-agents-folder.png)

---

# Task 2 — Compare the Agent Configurations

## Goal

Analyze the configuration differences between the three agents and demonstrate understanding of model and tool selection.

### Written Answers

#### 1. Why does the cost optimizer use Haiku instead of Sonnet?

The cost optimizer runs a fast, checklist-style scan of the Terraform (CloudFront price class, S3 storage class, lifecycle rules, cache settings) rather than deep reasoning. Haiku is faster and cheaper, which suits a lightweight, frequently-run check. Using Sonnet would cost more and run slower for no real gain, so Haiku is the deliberate choice. There is also a fitting logic to it: a cost-optimization agent should itself be cost-optimized. In my run, the cost optimizer finished in about 38 seconds on Haiku, while the security auditor took about 2 minutes 22 seconds on Sonnet.

---

#### 2. Why does the security auditor NOT have Write in its tools list?

The security auditor's job is to review and report, not to change anything. Without Write access it physically cannot modify the infrastructure it is auditing, which removes any risk of it altering the Terraform and keeps the review objective. This is least privilege: the agent gets only the tools its task needs (Read, Grep, Glob) and nothing more. My audit report confirmed this in practice, it stated explicitly that no files were modified.

---

#### 3. Why does the tf-writer use `inherit` instead of a specific model?

Generating Terraform is the most complex and highest-stakes of the three tasks, so it should run on the strongest model available. `inherit` makes tf-writer use the same model as the main session (Opus, in my setup) instead of being pinned to a fixed one. That keeps its quality aligned with the parent session and means it automatically benefits from any future model upgrade without editing the agent file.

---

### Evidence

#### Screenshot 2 — `security-auditor.md` frontmatter showing model and tools configuration

![Screenshot 2](./screenshots/a4-2-security-auditor.png)

---

#### Screenshot 3 — `cost-optimizer.md` frontmatter showing the model and tools configuration

![Screenshot 3](./screenshots/a4-3-cost-optimizer.png)

---

# Task 3 — Run the Security Auditor

## Goal

Trigger the security auditor agent and analyze the generated security report for your Terraform infrastructure.

### Evidence

#### Screenshot 4 — The delegation message showing Claude launched the security-auditor

![Screenshot 4](./screenshots/a4-4-delegation.png)

---

#### Screenshot 5 — Security audit report output

![Screenshot 5](./screenshots/a4-5-security-report.png)

---

# Task 4 — Run the Cost Optimizer

## Goal

Trigger the cost optimizer agent and review the generated cost optimization report.

### Evidence

#### Screenshot 6 — The full cost optimization report

![Screenshot 6](./screenshots/a4-6-cost-report.png)

---

# Submission Instructions

- Ensure all agent files are committed in `.claude/agents/`
- Complete all written answers in your GitHub Repo
- Push final changes to your forked GitHub repository

---

## GitHub Repository URL

Paste your forked repository URL here:

https://github.com/gbadedata/Ultimate-Agentic-DevOps-with-Claude-Code

Submission repository (screenshots and write-ups): https://github.com/gbadedata/devops-micro-internship-pravinmishra

---

# Completion Checklist

- [x] `.claude/agents/` folder contains all 3 agent files
- [x] Screenshot 2 shows correct `security-auditor.md` configuration
- [x] Screenshot 3 shows correct `cost-optimizer.md` configuration
- [x] All 3 written answers completed 
- [x] Security auditor executed successfully
- [x] Cost optimizer executed successfully
- [x] Security report is visible with findings
- [x] Cost report is visible with recommendations
- [x] All required screenshots added
- [x] GitHub repo updated with agents

---

## 📌 About DMI & CloudAdvisory

DevOps Micro Internship (DMI) is a project-based DevOps program run by Pravin Mishra (The CloudAdvisory) focused on real-world execution, systems thinking, and career readiness.

It helps learners build strong DevOps foundations with hands-on experience.

---

## 📌 Resources

- 🌐 DMI Official Website: https://pravinmishra.com/dmi  
- 🎓 DevOps for Beginners (Udemy): https://www.udemy.com/course/devops-for-beginners-docker-k8s-cloud-cicd-4-projects/  
- 🎓 Agentic AI DevOps with Claude Code: https://www.udemy.com/course/ultimate-agentic-ai-devops-with-claude-code/  
- 🎓 DevOps with Claude Code: Terraform, EKS, ArgoCD & Helm: https://www.udemy.com/course/devops-with-claude-code-terraform-eks-argocd-helm/  
- ▶️ YouTube Playlist: https://www.youtube.com/playlist?list=PLFeSNDtI4Cho  
- 🔗 Pravin Mishra (LinkedIn): https://www.linkedin.com/in/pravin-mishra-aws-trainer/  
- 🏢 CloudAdvisory (LinkedIn): https://www.linkedin.com/company/thecloudadvisory/

---

*This submission is part of DevOps Micro Internship (DMI) Cohort 3 — Agentic AI Track.*