# Assignment 2 — Stand Up Scrum in Jira for the DevOps Micro-Internship Website

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will configure a private, team-managed Scrum project in Jira Cloud for a DevOps Micro-Internship Website improvement and deployment initiative. You will build the complete work hierarchy and delivery workflow: Project → Epic → Stories → Sub-tasks → Labels → Sprint → Filters → Reports.

---

# Task 1 — Create the Jira Project (Team-Managed Scrum)

## Goal

Create a private, team-managed Scrum project named `DevOps Micro-Internship Website – <YourName>`.

### Evidence

#### Screenshot 1 — Project confirmation or project sidebar showing the project name and key

![Jira space directory showing the space name, key SCRUM, type Team-managed software, and lead](screenshots/a2-01-project-confirmation.png)

The Jira space directory, showing the space name, the key `SCRUM`, the type Team-managed software, and my name as space lead.

Two supporting captures below, because the private and team-managed properties are not visible in the directory listing itself.

![Space settings Access page confirming private access](screenshots/a2-01-private-access.png)

Space settings confirming private access, with the padlock indicator and the confirmation notice.

![Space menu stating Software space, Team-managed](screenshots/a2-01-team-managed.png)

The space menu stating "Software space, Team-managed" explicitly.

---

# Task 2 — Create Your First Epic from the Backlog

## Goal

Create the Epic `Polish DMI Website UI & Deploy` to group the website UI and deployment work.

### Evidence

#### Screenshot 2 — Backlog showing the Epic panel enabled and the Epic visible

![Backlog showing the Epic chip on every Story row](screenshots/a2-02-epic-created.png)

The Epic `Polish DMI Website UI & Deploy` was created as SCRUM-1 and appears as a chip on every Story row in the backlog. This version of Jira groups work items by parent rather than offering a separate Epic panel, so the Epic association is displayed inline on each row instead of in a side panel.

---

# Task 3 — Seed the Product Backlog with Six Stories

## Goal

Create all six required Stories (S1–S6) under the Epic, each with its description, Gherkin acceptance criteria, Fibonacci story point estimate (1, 2, or 3), and label, and assign every Story to yourself.

### Evidence

#### Screenshot 3 — Backlog showing the Epic and all six Stories under it

![Backlog showing all six Stories with Epic chips, points and assignee](screenshots/a2-03-six-stories.png)

All six Stories, SCRUM-2 through SCRUM-7, each linked to the Epic and assigned to me. The backlog total reads 10 Story Points, which matches the individual estimates of 2, 1, 3, 1, 2 and 1.

Only two of the six Stories are named in the assignment: S2 (primary button color refresh) and S4 (footer with version and date). The other four are not defined anywhere in the course repository, so I wrote them myself as frontend polish items consistent with the Epic and with the label split that Task 5 requires.

---

#### Screenshot 4 — One opened Story showing its Story point estimate, acceptance criteria, and label

![SCRUM-2 open, showing description, Gherkin acceptance criteria, label and story points](screenshots/a2-04-story-detail.png)

SCRUM-2 with its description, Gherkin acceptance criteria, the `frontend` label and a 2 point estimate. Team-managed Jira has no dedicated acceptance criteria field, so the Gherkin sits inside the description under its own heading, in a code block so the Given/When/Then indentation survives.

---

# Task 4 — Add Sub-tasks to at Least Two Stories

## Goal

Break down S2 (Primary button color refresh) and S4 (Footer with version and date) into the four required execution Sub-tasks each: Edit HTML/CSS, Test locally, Deploy to EC2, Verify and screenshot.

### Evidence

#### Screenshot 5 — S2 showing all four Sub-tasks

![SCRUM-3 showing its four sub-tasks alongside the assignee panel](screenshots/a2-05-s2-subtasks.png)

S2 is SCRUM-3. Its four sub-tasks are SCRUM-8 through SCRUM-11: Edit HTML/CSS, Test locally, Deploy to EC2, and Verify and screenshot.

---

#### Screenshot 6 — S4 showing all four Sub-tasks

![SCRUM-5 showing its four sub-tasks and the devops label](screenshots/a2-06-s4-subtasks.png)

S4 is SCRUM-5. Its four sub-tasks are SCRUM-12 through SCRUM-15, covering the same four execution steps. The `devops` label is visible in the details panel.

---

# Task 5 — Tag Stories by Workstream

## Goal

Apply the `frontend` label to S1, S2, S3, S5, and S6, and the `devops` label to S4, so every Story has at least one label.

### Evidence

#### Screenshot 7 — Backlog or Story details showing labels applied to at least two visible Stories

![Filtered work item list showing all six Stories with their labels](screenshots/a2-07-labels.png)

All six Stories shown with a labels column: `frontend` on five of them and `devops` on SCRUM-5, so every Story carries at least one label.

---

# Task 6 — Create and Start Sprint 1

## Goal

Create a one-week Sprint, move two or three Stories into it (approximately 3–5 Story Points), set the required Sprint Goal, and start the Sprint.

### Evidence

#### Screenshot 8 — Sprint 1 before starting, showing the selected Stories and Story Points

![Sprint 1 before starting, showing three Stories and five Story Points](screenshots/a2-08-sprint-before-start.png)

Sprint 1 before starting, dated 31 July to 7 August, holding SCRUM-3, SCRUM-4 and SCRUM-5 for a total of 5 Story Points. The remaining three Stories stay in the backlog rather than being pulled into the first Sprint.

---

#### Screenshot 9 — Active Sprint board showing the started Sprint and Sprint Goal

![Active sprint board showing the sprint goal and seven days remaining](screenshots/a2-09-active-sprint.png)

The active Sprint board after starting Sprint 1, showing seven days remaining and the start and end dates.

Sprint Goal: Ship a visibly improved and mobile-usable DMI website to EC2, with a versioned footer that proves the deployment date.

---

# Task 7 — Filter Stories, Sub-tasks, and Status

## Goal

Filter Jira work by the `frontend` and `devops` labels and review Stories with Sub-tasks and their current statuses.

### Evidence

#### Screenshot 10 — Filter for label = frontend showing the filtered results

![Filter results for label equals frontend, returning five Stories](screenshots/a2-10-filter-frontend.png)

Filtering on `labels = frontend` returns five Stories: SCRUM-2, SCRUM-3, SCRUM-4, SCRUM-6 and SCRUM-7.

---

#### Screenshot 11 — Filter for label = devops showing the filtered results

![Filter results for label equals devops, returning one Story](screenshots/a2-11-filter-devops.png)

Filtering on `labels = devops` returns a single result, SCRUM-5. One result is correct here, since the footer Story is the only item tagged as devops work.

---

# Task 8 — Open the Burndown Report

## Goal

Locate the Burndown Chart for Sprint 1 so it is ready for later progress tracking. It is acceptable if the chart has little or no data since the Sprint has just started.

### Evidence

#### Screenshot 12 — Burndown Chart page opened for Sprint 1

![Sprint burndown chart showing zero points done and five points to go](screenshots/a2-12-burndown.png)

The Sprint burndown for Sprint 1, reading 0 points done and 5 points to go, plotted against the guideline. This version of Jira surfaces the burndown through the Sprint insights panel rather than a separate Reports page. The chart is flat because the Sprint has only just started, which the task notes is expected.

---

# Submission Instructions

- Add all required screenshots in your submission
- Full name must be visible in required screenshots
- Do not expose sensitive information (passwords, verification codes, account recovery details)

---

# Completion Checklist

- [x] Task 1: Private team-managed Scrum project created with your name (Screenshot 1)
- [x] Task 2: Epic "Polish DMI Website UI & Deploy" created (Screenshot 2)
- [x] Task 3: All six Stories connected to the Epic, assigned to you, with descriptions/acceptance criteria/points/labels (Screenshots 3 & 4)
- [x] Task 4: Four Sub-tasks created under both S2 and S4 (Screenshots 5 & 6)
- [x] Task 5: Frontend and devops labels applied to all Stories (Screenshot 7)
- [x] Task 6: One-week Sprint 1 started with the required Sprint Goal (Screenshots 8 & 9)
- [x] Task 7: Frontend and devops filters demonstrated (Screenshots 10 & 11)
- [x] Task 8: Burndown Chart opened for Sprint 1 (Screenshot 12)
- [x] Full Name visible in required screenshots
- [x] No sensitive data exposed

---

## 📌 About DMI & CloudAdvisory

DevOps Micro Internship (DMI) is a project-based DevOps program run by Pravin Mishra (The CloudAdvisory) focused on real-world execution, systems thinking, and career readiness.

It helps learners build strong DevOps foundations with hands-on experience.

---

## 📌 Resources

- 🌐 DMI Official Website: https://dmi.pravinmishra.com?utm_source=github&utm_medium=readme  
- 🎓 University: https://university.pravinmishra.com?utm_source=github&utm_medium=readme  
- 💬 Discord Community: https://discord.pravinmishra.com?utm_source=github&utm_medium=readme  
- 📝 Blog: https://dmi.pravinmishra.com/blog?utm_source=github&utm_medium=readme  
- ▶️ YouTube Playlist: https://www.youtube.com/playlist?list=PLFeSNDtI4Cho  
- 🔗 Pravin Mishra (LinkedIn): https://www.linkedin.com/in/pravin-mishra-aws-trainer/  
- 🏢 CloudAdvisory (LinkedIn): https://www.linkedin.com/company/thecloudadvisory/

---

*This submission is part of DevOps Micro Internship (DMI) Cohort 3 — Agentic AI Track.*
