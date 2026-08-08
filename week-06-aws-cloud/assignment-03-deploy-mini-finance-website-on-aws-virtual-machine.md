# Assignment 3 — Deploy Mini Finance Website on AWS Virtual Machine

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will deploy the Mini Finance static HTML website on an AWS EC2 Linux virtual machine. You will launch the server, configure network access, connect through SSH, install a web server, deploy the GitHub source files, and confirm the website is reachable through the EC2 public IP.

---

# Task 1 — Launch and Secure an EC2 Linux Instance

## Goal

Launch an Amazon Linux 2 or Ubuntu EC2 instance in a public subnet, and configure its security group to allow SSH (22) and HTTP (80).

> No screenshot required for this task. Completion is verified through Task 4.

---

# Task 2 — Connect via SSH and Install a Web Server

## Goal

Connect to the instance using SSH and install Nginx or Apache.

> No screenshot required for this task. Completion is verified through Task 4.

---

# Task 3 — Clone and Deploy the Mini Finance Site

## Goal

Clone the Mini Finance repository (`https://github.com/pravinmishraaws/mini_finance.git`) and copy the site files to the web server's root directory.

> No screenshot required for this task. Completion is verified through Task 4.

---

# Task 4 — Start the Web Server and Verify the Website

## Goal

Start the web server and confirm the Mini Finance website is accessible through the EC2 public IP.

### Evidence

#### Screenshot 1 — Browser showing the Mini Finance website running at the EC2 public IP

![Mini Finance website loaded in the browser at the EC2 public IP](./screenshots/a3-01-mini-finance-live.png)

---

#### Public IP URL

Paste the public IP address of your EC2 instance here (e.g. `http://3.91.105.10`):

`http://35.179.116.145`

### Deployment summary

I launched an Ubuntu 24.04 t3.micro instance in a public subnet of the default VPC in eu-west-2, with a security group allowing HTTP on port 80 from anywhere and SSH on port 22 restricted to my own IP address rather than the whole internet. After connecting over SSH I installed Nginx, enabled it to start on boot, then cloned the Mini Finance repository and copied the site files into the web root at /var/www/html.

Two details mattered. I deleted Nginx's default index.nginx-debian.html first, because the default server block lists several index filenames and leaving the Ubuntu placeholder in place risks it being served instead of the real homepage. I also removed the repository's README, template notes, and git tracking summary from the web root, since those are repository files rather than website content and serving them publicly exposes internal detail for no benefit. Before opening a browser I checked the deployment locally with curl against localhost, which returned 200 and confirmed that any remaining failure would be a network or security group problem rather than a web server one.

---

# Submission Instructions

- Add the required screenshot in your submission
- Include the EC2 Public IP URL
- Do not expose private keys, passwords, or account IDs

---

# Completion Checklist

- [x] EC2 instance launched in a public subnet with SSH (22) and HTTP (80) allowed
- [x] Connected to the instance via SSH
- [x] Web server (Nginx or Apache) installed
- [x] Mini Finance repository cloned and files copied to the web server root
- [x] Web server started and website verified in the browser (Screenshot 1)
- [x] EC2 Public IP URL included
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
