# Assignment 3 — Docker Networking

Part of the DevOps Micro Internship (DMI) with Agentic AI

---

## Purpose

In this assignment, you will explore Docker networking by using default bridge, custom bridge, multiple bridge, and host network modes. You will verify container communication, service discovery, network isolation, public access, and host networking on a Linux VM or EC2 instance.

---

# Task 1 — Deploy a Standalone Application Using the Default Bridge Network

## Goal

Deploy an Nginx web server using Docker’s default bridge network and access it through the VM public IP address.

### Evidence

#### Screenshot 1 — Available Docker Networks

Add a screenshot of the terminal showing:

```bash
docker network ls
```

The output must include the default `bridge`, `host`, and `none` networks.

![docker network ls showing bridge, host and none](./screenshots/a3-01-network-ls-default.png)

---

#### Screenshot 2 — Nginx Image Pull

Add a screenshot of the terminal showing successful completion of:

```bash
docker pull nginx:alpine
```

![docker pull nginx:alpine](./screenshots/a3-02-nginx-pull.png)

---

#### Screenshot 3 — Running `myweb` Container

Add a screenshot of the terminal showing:

```bash
docker ps
```

The output must show the running `myweb` container with:

```text
0.0.0.0:80->80/tcp
```

![docker ps showing myweb on 0.0.0.0:80->80/tcp](./screenshots/a3-03-docker-ps-myweb.png)

---

#### Screenshot 4 — Nginx Welcome Page

Add a browser screenshot showing the Nginx Welcome Page at:

```text
http://<YOUR-VM-PUBLIC-IP>
```

Ensure that the VM public IP is visible in the address bar. Add your full name as a clear caption directly below the screenshot.

![Nginx welcome page from myweb at the VM public IP](./screenshots/a3-04-nginx-default-bridge.png)

*Oluwagbade Odimayo*

---

# Task 2 — Connect Containers Using a Custom Bridge Network

## Goal

Create a custom bridge network and verify that containers can communicate using container names rather than IP addresses.

### Evidence

#### Screenshot 5 — Custom Bridge Network Created

Add a screenshot of the terminal showing `mynetwork` in:

```bash
docker network ls
```

![docker network ls showing mynetwork](./screenshots/a3-05-network-ls-mynetwork.png)

---

#### Screenshot 6 — Running `web` and `client` Containers

Add a screenshot of the terminal showing:

```bash
docker ps
```

The output must show both `web` and `client` containers running without published host ports.

![docker ps showing web and client with no published ports](./screenshots/a3-06-docker-ps-web-client.png)

---

#### Screenshot 7 — Service Discovery by Container Name

Add a screenshot of the terminal showing successful output from:

```bash
docker exec client wget -qO- http://web
```

The output must display the Nginx Welcome Page HTML.

![client reaching web by container name](./screenshots/a3-07-client-to-web-by-name.png)

---

#### Screenshot 8 — Custom Network Inspection

Add a screenshot of the terminal showing:

```bash
docker network inspect mynetwork
```

The output must show both `web` and `client` connected to `mynetwork`.

![docker network inspect mynetwork showing web and client](./screenshots/a3-08-inspect-mynetwork.png)

---

# Task 3 — Demonstrate Multi-Network Isolation

## Goal

Deploy frontend, backend, and database containers across two separate Docker networks. Verify allowed communication and confirm that the frontend cannot directly reach the database.

### Evidence

#### Screenshot 9 — Two Docker Networks

Add a screenshot of the terminal showing:

```bash
docker network ls
```

The output must include both `frontend-network` and `backend-network`.

![docker network ls showing frontend-network and backend-network](./screenshots/a3-09-network-ls-two-networks.png)

---

#### Screenshot 10 — Running Multi-Network Containers

Add a screenshot of the terminal showing:

```bash
docker ps
```

The output must show:

- `frontend` with the published port mapping `0.0.0.0:80->80/tcp`
- `backend` without a published host port
- `db` without a published host port

![docker ps showing frontend on port 80, backend and db unpublished](./screenshots/a3-10-docker-ps-three-tier.png)

---

#### Screenshot 11 — Frontend Network Inspection

Add a screenshot of the terminal showing:

```bash
docker network inspect frontend-network
```

The output must show `frontend` and `backend`.

![docker network inspect frontend-network showing frontend and backend](./screenshots/a3-11-inspect-frontend-network.png)

---

#### Screenshot 12 — Backend Network Inspection

Add a screenshot of the terminal showing:

```bash
docker network inspect backend-network
```

The output must show `backend` and `db`.

![docker network inspect backend-network showing backend and db](./screenshots/a3-12-inspect-backend-network.png)

---

#### Screenshot 13 — Frontend-to-Backend Communication

Add a screenshot of the terminal showing successful output from:

```bash
docker exec frontend wget -qO- http://backend
```

The output must display the Nginx Welcome Page HTML.

![frontend reaching backend by name](./screenshots/a3-13-frontend-to-backend.png)

---

#### Screenshot 14 — Backend-to-Database Communication

Add a screenshot of the terminal showing a successful connection to `db` on port `27017` from the `backend` container.

![backend connecting to db on port 27017](./screenshots/a3-14-backend-to-db.png)

---

#### Screenshot 15 — Frontend-to-Database Isolation

Add a screenshot of the terminal showing that the `frontend` container cannot reach `db` on port `27017`.

The output must include:

```text
Expected result: frontend cannot reach db
```

![frontend unable to reach db by name or by IP](./screenshots/a3-15-frontend-to-db-blocked.png)

---

#### Screenshot 16 — Public Frontend Access

Add a browser screenshot showing the Nginx Welcome Page from the `frontend` container at:

```text
http://<YOUR-VM-PUBLIC-IP>
```

Ensure that the VM public IP is visible in the address bar. Add your full name as a clear caption directly below the screenshot.

![Nginx welcome page from the frontend container at the VM public IP](./screenshots/a3-16-nginx-frontend-public.png)

*Oluwagbade Odimayo*

---

# Task 4 — Deploy an Application Using Docker Host Network Mode

## Goal

Run an Nginx container using Docker host network mode and compare it with bridge networking.

### Evidence

#### Screenshot 17 — Running Host-Networked Container

Add a screenshot of the terminal showing:

```bash
docker ps
```

The output must show the running `fastapp` container.

![docker ps showing fastapp](./screenshots/a3-17-docker-ps-fastapp.png)

---

#### Screenshot 18 — Host Network Mode Verification

Add a screenshot of the terminal showing output from:

```bash
docker inspect fastapp | grep '"NetworkMode"'
```

The output must confirm:

```text
"NetworkMode": "host"
```

![docker inspect confirming NetworkMode host](./screenshots/a3-18-fastapp-networkmode-host.png)

---

#### Screenshot 19 — Host-Networked Nginx Page

Add a browser screenshot showing the Nginx Welcome Page at:

```text
http://<YOUR-VM-PUBLIC-IP>
```

Ensure that the VM public IP is visible in the address bar. Add your full name as a clear caption directly below the screenshot.

![Nginx welcome page from the host-networked fastapp container](./screenshots/a3-19-nginx-host-mode.png)

*Oluwagbade Odimayo*

---

#### Screenshot 20 — Host-Networked Container Cleanup

Add a screenshot of the terminal showing successful completion of:

```bash
docker stop fastapp
docker rm fastapp
```

![docker stop and docker rm fastapp](./screenshots/a3-20-fastapp-cleanup.png)

---

# Networking Notes

Write a short note explaining:

- Default bridge networking
- Container-name communication on a custom bridge network
- Why the frontend could not access the database in Task 3
- The difference between bridge mode and host network mode

**Default bridge networking.** In Task 1, `myweb` ran on Docker's default `bridge` network. Docker gave it a private IP on the VM's `docker0` bridge, and `-p 80:80` published its port 80 on the VM, which is why the page loaded from the public IP. The default bridge has no DNS between containers, so containers on it can only find each other by IP address.

**Container-name communication on a custom bridge.** On `mynetwork`, Docker's built-in DNS resolves container names, so `client` reached `web` at `http://web` without knowing any IP. Neither container published a port, so that traffic never left the Docker network.

**Why the frontend could not reach the database.** `frontend` is only on `frontend-network`, `db` is only on `backend-network`, and `backend` is the one container attached to both. Screenshot 15 shows two separate failures. The name `db` does not resolve from `frontend`, because Docker only answers DNS for containers on a shared network. Connecting straight to `db`'s IP also times out, because Docker drops traffic between separate bridge networks. That is the layout of a real three-tier app: only the frontend is public, and the database is reachable only from the tier that needs it.

**Bridge mode vs host network mode.** In bridge mode each container gets its own network namespace and IP, and outside traffic reaches it only through a `-p` mapping that Docker handles with NAT. In host mode, `fastapp` shared the VM's network stack directly. Nginx bound to port 80 on the VM itself, `docker ps` showed no port mapping, and `NetworkMode` was `host`. Host mode removes the NAT hop, but it also removes network isolation, and two containers can no longer both listen on the same port.

---

# LinkedIn Requirement

## Goal

Create a LinkedIn post about the Docker networking modes explored, one key lesson about container isolation, and the learning outcomes from this assignment.

### Evidence

#### LinkedIn Post URL

Paste your LinkedIn post URL here:

Not published, by choice.

---

#### LinkedIn Post Screenshot

Not published, by choice.

---

# Submission Instructions

- Complete all tasks in sequence.
- Include Screenshots 1–20 exactly as specified.
- Include the Networking Notes section.
- Include the LinkedIn post URL and screenshot.
- Ensure that your full name is visible in all terminal screenshots.
- Add your full name as a caption below each browser screenshot that shows the standard Nginx page.
- Do not expose private keys, passwords, access keys, tokens, account IDs, or other sensitive information.

---

# Completion Checklist

- [x] Completed on a Linux VM or EC2 instance
- [x] Docker Engine is running
- [x] HTTP port 80 is allowed in the VM firewall or cloud security rules
- [x] Default bridge networking verified
- [x] Custom bridge network created
- [x] Container-name communication verified
- [x] `frontend-network` and `backend-network` created
- [x] Frontend-to-backend communication verified
- [x] Backend-to-database communication verified
- [x] Frontend-to-database isolation verified
- [x] Only the frontend published port 80 in Task 3
- [x] Host network mode verified
- [x] All required screenshots included
- [x] Networking Notes completed
- [ ] LinkedIn post URL and screenshot included (not published, by choice)
- [x] Full name visible in terminal screenshots
- [x] Browser screenshots include full-name captions
- [x] No sensitive information exposed

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

*This submission is part of DevOps Micro Internship (DMI) — Agentic AI Track.*
