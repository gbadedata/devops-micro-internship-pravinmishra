# Assignment 5 — Deploy a Highly Available Two-Tier Application on AWS

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will design and deploy a highly available two-tier web application on AWS: highly available networking across two Availability Zones, an Application Load Balancer, an Auto Scaling Group for the web tier, and a private Multi-AZ RDS database. You must prove high availability with real failure tests.

---

# Task 1 — Create HA Networking (VPC + 4 Subnets + IGW + NAT + Route Tables)

## Goal

Build a VPC (10.0.0.0/16) with two public and two private subnets across two Availability Zones, an Internet Gateway, a NAT Gateway, and the matching public/private route tables.

### Evidence

#### Screenshot 1 — VPC details showing CIDR 10.0.0.0/16

![ha-vpc showing IPv4 CIDR 10.0.0.0/16](./screenshots/a5-01-vpc-details.png)

---

#### Screenshot 2 — Subnets list showing four subnets and their Availability Zones

![Four subnets across eu-west-2a and eu-west-2b with their CIDR blocks](./screenshots/a5-02-subnets.png)

---

#### Screenshot 3 — Public route table showing the Internet Gateway route and both public-subnet associations

![Public route table with the 0.0.0.0/0 route to the internet gateway and both public subnets associated](./screenshots/a5-03-public-route-table.png)

---

#### Screenshot 4 — Private route table showing the NAT Gateway route and both private-subnet associations

![Private route table with both private subnets explicitly associated](./screenshots/a5-04-private-route-table.png)

![Private route table routes tab showing 0.0.0.0/0 pointing at the NAT gateway](./screenshots/a5-04b-private-route-nat.png)

---

#### Screenshot 5 — NAT Gateway status showing Available and the Elastic IP

![NAT gateway ha-nat-gw available in public-subnet-a with its Elastic IP](./screenshots/a5-05-nat-gateway.png)

---

# Task 2 — Create Security Groups (ALB, EC2, RDS) with Least Privilege

## Goal

Create `ha-alb-sg` (HTTP public), `ha-web-sg` (HTTP only from `ha-alb-sg`, SSH from your IP), and `ha-db-sg` (database port only from `ha-web-sg`).

### Evidence

#### Screenshot 6 — ALB Security Group inbound rules

![ha-alb-sg allowing HTTP on port 80 from 0.0.0.0/0](./screenshots/a5-06-alb-sg.png)

---

#### Screenshot 7 — EC2 Security Group inbound rules showing the ALB Security Group reference and SSH from your IP

![ha-web-sg allowing HTTP from the ALB security group and SSH from a single admin IP](./screenshots/a5-07-web-sg.png)

---

#### Screenshot 8 — RDS Security Group inbound rule showing the database port allowed only from the EC2 Security Group

![ha-db-sg allowing MySQL on 3306 only from the web tier security group](./screenshots/a5-08-db-sg.png)

---

# Task 3 — Deploy Database Tier (RDS Multi-AZ in Private Subnets)

## Goal

Launch a private, Multi-AZ RDS database (MySQL or PostgreSQL) using the private DB Subnet Group and `ha-db-sg`.

### Evidence

#### Screenshot 9 — RDS summary showing Multi-AZ = Yes and Publicly accessible = No

![RDS instance ha-db with Multi-AZ set to Yes and a standby in the second Availability Zone](./screenshots/a5-09-rds-multi-az.png)

---

#### Screenshot 10 — RDS connectivity section showing the DB Subnet Group and Security Group

![RDS connectivity showing the private DB subnet group, ha-db-sg, and Publicly accessible set to No](./screenshots/a5-10-rds-connectivity.png)

---

# Task 4 — Build a Launch Template (User Data Installs App + Connects to DB)

## Goal

Create a Launch Template whose user data installs the web-server runtime, deploys the application, configures the database connection, and starts the required services.

### Evidence

#### Screenshot 11 — Launch Template details showing that user data exists, including a visible snippet

![Launch template user data showing the package install and application deployment steps](./screenshots/a5-11-launch-template.png)

![Launch template details showing the AMI, instance type, security group and key pair](./screenshots/a5-11b-launch-template-details.png)

---

#### Screenshot 12 — A running instance created from the template showing the application responds on port 80

![Instance launched from the template serving the application on port 80](./screenshots/a5-12-instance-responds.png)

---

# Task 5 — Create an Application Load Balancer (ALB) Across 2 Public Subnets

## Goal

Create an internet-facing ALB across both public subnets with an HTTP listener and a healthy instance target group.

### Evidence

#### Screenshot 13 — ALB details showing two public subnets in two Availability Zones

![ha-alb spanning public-subnet-a and public-subnet-b across two Availability Zones](./screenshots/a5-13-alb-subnets.png)

---

#### Screenshot 14 — Target group showing at least one healthy target

![Target group ha-tg showing healthy targets](./screenshots/a5-14-target-group-healthy.png)

---

# Task 6 — Create Auto Scaling Group (ASG) in 2 Public Subnets

## Goal

Create an Auto Scaling Group from the Launch Template across both public subnets, with desired capacity 2, minimum 2, and maximum 4, registered to the ALB target group.

### Evidence

#### Screenshot 15 — Auto Scaling Group showing desired, minimum, and maximum capacity and the selected subnet Availability Zones

![Auto Scaling group ha-asg with desired 2, minimum 2, maximum 4, across both Availability Zones](./screenshots/a5-15-asg-capacity.png)

---

#### Screenshot 16 — EC2 instances list showing two running instances in different Availability Zones

![Two running instances, one in eu-west-2a and one in eu-west-2b](./screenshots/a5-16-asg-instances-two-azs.png)

---

# Task 7 — Configure App to Use RDS + Validate Read/Write

## Goal

Confirm the application communicates with the RDS database through the ALB DNS name with at least one read and one write operation.

### Evidence

#### Screenshot 17 — Browser showing the application loaded through the ALB DNS name with the URL visible

![Application loaded in the browser through the ALB DNS name](./screenshots/a5-17-app-via-alb.png)

---

#### Screenshot 18 — Proof of a database write through a UI message or database query output

![Dashboard confirming the write, showing the site title, the created user, and one published post, page and comment](./screenshots/a5-18-database-write.png)

![The same record read back out of RDS and rendered through the load balancer](./screenshots/a5-18b-database-read.png)

---

# Task 8 — High Availability Tests (Must Do Both)

## Goal

Test A: terminate one web instance and confirm the Auto Scaling Group replaces it automatically without interrupting the ALB. Test B: simulate an Availability Zone impact (stop, detach, or reduce desired capacity in one AZ) and confirm the application stays available.

### Evidence

#### Screenshot 19 — EC2 showing the terminated instance and the newly launched instance

![The terminated instance alongside its automatically launched replacement, both in eu-west-2a](./screenshots/a5-19-terminated-and-replaced.png)

---

#### Screenshot 20 — Target group showing healthy targets after replacement

![Target group healthy again after the Auto Scaling group replaced the terminated instance](./screenshots/a5-20-target-group-after-replacement.png)

---

#### Screenshot 21 — Evidence that an instance was removed, detached, placed in Standby, or stopped in one Availability Zone

![Desired capacity reduced to one, draining the eu-west-2a instance while eu-west-2b stays in service](./screenshots/a5-21-az-impact-simulated.png)

---

#### Screenshot 22 — Browser showing that the ALB DNS endpoint still works during the change

![Continuous HTTP 200 responses from the ALB spanning the Availability Zone impact](./screenshots/a5-22-alb-works-during-az-impact.png)

---

# Task 9 — Architecture and Test-Results Summary

## Goal

Summarize the VPC/subnet layout, the ALB and Auto Scaling Group setup, the private Multi-AZ RDS setup, and the results of both high-availability tests.

### Evidence

#### Screenshot 23 — A simple architecture diagram (hand-drawn is fine), or an AWS console overview showing the components

![Architecture diagram of the VPC, subnets, ALB, Auto Scaling group and Multi-AZ RDS](./screenshots/a5-23-architecture-diagram.png)

---

### Additional evidence

#### Auto Scaling group healing captured mid-replacement

![Terminating instance, its replacement already in service, and the untouched instance in the second zone](./screenshots/a5-20b-asg-healing-in-progress.png)

All three states in one view: the terminated instance winding down as unhealthy, its replacement already in service in the same Availability Zone, and the instance in the other zone untouched. The replacement went back into the zone that lost capacity rather than simply topping up the total, which is what preserves zone-level redundancy after a failure instead of leaving both instances in one place.

#### Load balancer continuity during the instance failure test

![Continuous successful responses from the ALB spanning the instance termination in Test A](./screenshots/a5-21-alb-still-serving.png)

The same curl loop used in Test B, run during Test A. Two independent mechanisms are working here: the load balancer stops routing to the failing instance once its health check fails, and separately the Auto Scaling group notices capacity has dropped and launches a replacement. Neither knows about the other, and the user data script is what makes the replacement useful rather than an empty server.

#### Multi-AZ database failover

![RDS event log showing the Multi-AZ failover starting and completing, with the primary and standby zones swapped](./screenshots/a5-22-rds-failover.png)

I forced a Multi-AZ failover with a reboot to test the database tier directly, which the assignment does not require. The primary moved from eu-west-2a to eu-west-2b and the former primary became the standby. The endpoint hostname did not change, because AWS repoints the DNS record at the promoted instance, so every web instance kept its existing configuration and reconnected without intervention. That is the reason the launch template hardcodes an endpoint rather than an address.

---

### Notes

Write a short summary covering the network, ALB/ASG setup, RDS setup, and the results of Test A and Test B.

**Network.** A custom VPC on 10.0.0.0/16 with four subnets spread across eu-west-2a and eu-west-2b. Two public subnets (10.0.1.0/24 and 10.0.2.0/24) carry the load balancer and the web tier, and two private subnets (10.0.11.0/24 and 10.0.12.0/24) carry the database. A public route table sends 0.0.0.0/0 to the internet gateway and is associated with both public subnets. A separate private route table sends 0.0.0.0/0 to a NAT gateway in public-subnet-a, giving the private subnets outbound access without any inbound path from the internet. Creating that second route table was necessary rather than optional: a new subnet inherits the VPC main route table, which here carries the internet gateway route, so both private subnets would have been reachable by default.

**ALB and Auto Scaling.** An internet-facing Application Load Balancer spans both public subnets with an HTTP listener forwarding to the target group ha-tg. An Auto Scaling group runs desired 2, minimum 2, maximum 4 across both subnets, registered to that target group and using ELB health checks rather than EC2 status checks, so an instance that boots but fails to serve is treated as failed. Instances come from a launch template whose user data installs the web server and runtime, deploys the application, writes the database configuration, and starts the service, which is what makes an instance disposable and replaceable without manual work.

**RDS.** A db.t3.micro MySQL instance with Multi-AZ enabled, placed in a subnet group containing only the two private subnets, with Publicly accessible set to No. Access is controlled by a security group chain rather than by address ranges: the ALB group accepts HTTP from anywhere, the web tier accepts HTTP only from the ALB group and SSH only from my own address, and the database accepts port 3306 only from the web tier group. Because each rule references a security group rather than a CIDR, it keeps working as the Auto Scaling group launches and terminates instances with changing IP addresses.

**Test A, instance failure.** I terminated one web instance directly. The Auto Scaling group detected that capacity had fallen below desired and launched a replacement in the same Availability Zone within about three minutes, and the target group returned to two healthy targets once the new instance finished configuring itself. Throughout the replacement a curl loop against the ALB DNS name continued to return successful responses, because the load balancer stopped routing to the failing instance as soon as its health check failed while the instance in the other Availability Zone absorbed the traffic.

**Test B, Availability Zone impact.** I reduced desired capacity to one, which drained the eu-west-2a instance and left only eu-west-2b serving. A curl loop running throughout returned HTTP 200 on every request from 01:53:28 to 01:59:14, spanning the capacity change with no failures, no gateway errors and no dropped connections. Capacity was then restored to two and the Auto Scaling group rebalanced across both zones.

**What I would change.** The NAT gateway is a single point of failure. It sits in one Availability Zone, and both private subnets route through it, so losing eu-west-2a would remove outbound internet access for the private tier in both zones. A production design would run one NAT gateway per Availability Zone with a separate private route table for each. The web tier also sits in public subnets because the assignment specifies that, but a production build would place it in the private subnets and reach the internet through the NAT gateway, leaving only the load balancer publicly addressable.

---

# LinkedIn Post (Required)

## Goal

Publish a LinkedIn post about the high-availability build, including the ALB URL (or a redacted screenshot), three to five lines on what you built and how you tested high availability, and one proof screenshot.

## Evidence

#### LinkedIn Post URL

Paste your LinkedIn post URL here:

`Add your URL here`

---

#### Screenshot — Published LinkedIn post

TODO_LINKEDIN_SCREENSHOT

---

# Submission Instructions

- Add all required screenshots in your submission
- Do not expose passwords, connection strings, private keys, or account IDs

---

# Completion Checklist

- [ ] Task 1: VPC, four subnets, IGW, NAT Gateway, and route tables created (Screenshots 1–5)
- [ ] Task 2: Least-privilege ALB, EC2, and RDS security groups created (Screenshots 6–8)
- [ ] Task 3: Private Multi-AZ RDS created (Screenshots 9–10)
- [ ] Task 4: Self-configuring Launch Template created and tested (Screenshots 11–12)
- [ ] Task 5: ALB created across both public subnets (Screenshots 13–14)
- [ ] Task 6: Auto Scaling Group running two instances across two AZs (Screenshots 15–16)
- [ ] Task 7: Application verified through the ALB with a database read and write (Screenshots 17–18)
- [ ] Task 8: Both high-availability tests completed (Screenshots 19–22)
- [ ] Task 9: Architecture and test-results summary completed (Screenshot 23 & Notes)
- [ ] LinkedIn post published and URL submitted
- [ ] No sensitive data exposed

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
