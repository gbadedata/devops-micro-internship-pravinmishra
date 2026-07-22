# Assignment 2 — CodeTrack: Tracking, Staging, Committing + Deploy to EC2

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will track and stage project files, create two meaningful Git commits in `CodeTrack`, verify your commit history, and deploy the CodeTrack static website to an EC2 instance using Nginx. This connects local version-control practice with a basic manual deployment workflow used in real DevOps environments.

---

# Task 1 — Verify Git Setup and Enter the Repository

## Goal

Confirm that Git works and that you are inside the correct `CodeTrack` repository.

### Evidence

#### Screenshot 1 — Output of `pwd` showing you're inside `CodeTrack`

![Screenshot 1: pwd inside CodeTrack](screenshots/a2-01-pwd.png)

Confirmed I was inside the CodeTrack repository at C:/Users/gbade/CodeTrack before running any Git commands.

---

#### Screenshot 2 — Output of `git status` showing no "not a git repository" error

![Screenshot 2: git status](screenshots/a2-02-git-status.png)

git status returned a clean repository state with no "not a git repository" error, confirming Git was tracking this folder.

---

# Task 2 — Create index.html and style.css

## Goal

Create the two starter UI files inside `CodeTrack`.

### Evidence

#### Screenshot 3 — Output of `ls` showing `index.html` and `style.css`

![Screenshot 3: ls showing both files](screenshots/a2-03-ls-files.png)

Both index.html and style.css created and listed in the project folder.

---

# Task 3 — Add Starter Content

## Goal

Copy the provided starter HTML and CSS content into your local `index.html` and `style.css` files.

### Evidence

#### Screenshot 4 — Your editor showing the contents of `index.html` and `style.css`

![Screenshot 4a: index.html contents](screenshots/a2-04a-editor-index-html.png)

The starter HTML copied from the official DMI CodeTrack starter repository, still showing the untouched [Your Name] and [Your Group] placeholders on lines 37 and 38.

![Screenshot 4b: style.css contents](screenshots/a2-04b-editor-style-css.png)

The starter stylesheet in place, 203 lines in total.

---

# Task 4 — Track and Stage Files Correctly

## Goal

Confirm both files show as untracked, then stage them individually with `git add`.

### Evidence

#### Screenshot 5 — Output of `git status` showing both files as untracked

![Screenshot 5: files untracked](screenshots/a2-05-status-untracked.png)

Git reported both new files as untracked, meaning they existed on disk but were not yet part of the repository history.

---

#### Screenshot 6 — Output of `git status` showing both files staged under "Changes to be committed"

![Screenshot 6: files staged](screenshots/a2-06-status-staged.png)

After staging each file individually, both moved under "Changes to be committed".

---

# Task 5 — Create the First Commit (Clean Initial Commit)

## Goal

Commit the staged starter files using the message `Initial UI scaffold: add index.html and style.css`, then check the log.

### Evidence

#### Screenshot 7 — Output of `git commit`

![Screenshot 7: first commit](screenshots/a2-07-first-commit.png)

The initial commit recorded both files, 271 insertions in total.

---

#### Screenshot 8 — Output of `git log --oneline` showing the first commit

![Screenshot 8: log with one commit](screenshots/a2-08-log-one-commit.png)

git log --oneline confirmed a single commit in the history.

---

# Task 6 — Modify index.html and Create a Second Commit

## Goal

Follow the instruction comment inside `index.html` to update the Student Name and Group Name, then commit that change separately using the message `Update homepage content: heading, tagline, CTA button`.

### Evidence

#### Screenshot 9 — Browser showing the updated page with your Student Name and Group Name visible

![Screenshot 9: local browser with name and group](screenshots/a2-09-browser-local.png)

The page rendered locally with my full name and group number replacing the starter placeholders.

---

#### Screenshot 10 — Output of `git status` showing `index.html` as modified

![Screenshot 10: index.html modified](screenshots/a2-10-status-modified.png)

Git detected index.html as modified while style.css stayed untouched.

---

#### Screenshot 11 — Output of `git commit`

![Screenshot 11: second commit](screenshots/a2-11-second-commit.png)

Committed only the file I changed: 1 file changed, 2 insertions, 2 deletions.

---

#### Screenshot 12 — Output of `git log --oneline` showing two commits

![Screenshot 12: log with two commits](screenshots/a2-12-log-two-commits.png)

The history now shows two separate commits, scaffold first and content change second.

---

# Task 7 — Deploy to EC2 with Nginx (Static Website)

## Goal

Install and start Nginx on your EC2 instance, then copy `index.html` and `style.css` into the Nginx web root.

### Evidence

#### Screenshot 13 — Output of `systemctl status nginx --no-pager` showing Nginx `active (running)`

![Screenshot 13: nginx active running](screenshots/a2-13-nginx-status.png)

Nginx active (running) and enabled at boot on the EC2 instance.

---

#### Screenshot 14 — Output of `curl -I http://localhost` showing `HTTP/1.1 200 OK`

![Screenshot 14: curl 200 OK](screenshots/a2-14-curl-localhost.png)

curl -I http://localhost returned HTTP/1.1 200 OK from the server itself.

---

#### Screenshot 15 — Browser showing the CodeTrack site loaded at `http://<EC2_PUBLIC_IP>`, with your Full Name and Group Name visible

![Screenshot 15: deployed site on EC2](screenshots/a2-15-browser-ec2.png)

The deployed site loading over the public internet, with my full name and group number visible.

---

# LinkedIn Post (Required)

## Evidence

#### LinkedIn Post URL

Paste your LinkedIn post URL here:

`https://www.linkedin.com/posts/oluwagbade-odimayo-_dmibypravinmishra-devops-agenticai-activity-7485623139532521474-_oy3`

---

#### Screenshot — LinkedIn post showing the deployed CodeTrack application

![Screenshot: LinkedIn post](screenshots/a2-16-linkedin-post.png)

The published LinkedIn post with the deployed application attached.

---

# Submission Instructions

- Add all required screenshots in your submission
- Full Name and Group Name must be visible in the deployed application evidence
- `git log --oneline` output must show at least two meaningful commits
- Do not expose AWS access keys, passwords, private key contents, or other sensitive information

---

# Completion Checklist

- [x] `CodeTrack` repository verified with `git status` (Screenshots 1–2)
- [x] `index.html` and `style.css` created and populated (Screenshots 3–4)
- [x] Starter files staged and committed in the first commit (Screenshots 5–8)
- [x] Student Name and Group Name updated in `index.html` (Screenshot 9)
- [x] Second controlled commit created (Screenshots 10–12)
- [x] Nginx active on the EC2 instance and CodeTrack reachable via its public IP (Screenshots 13–15)
- [x] LinkedIn post published and URL submitted
- [x] No sensitive data exposed

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
