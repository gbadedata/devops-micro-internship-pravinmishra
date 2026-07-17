# Incident Summary: Nginx Outage

**Full Name:** Oluwagbade Odimayo
**Date:** 17/07/2026
**Host:** oluwagbade-odimayo (Ubuntu 24.04, AWS EC2 t3.micro, eu-west-2)
**Cohort:** DMI Cohort 3 | Group 3 | Week 3

---

## 1. Reported Symptom

The static site served by Nginx on port 80 stopped responding. A request to `http://localhost` returned no HTTP response at all rather than an error page. The service had been healthy at 20:38:10, with a triage report showing 5 PASS and an exit code of 0.

## 2. Evidence Collected

`./scripts/linux-triage.sh` was run at 20:42:46. It exited 1 and wrote `reports/incident-failure-report.txt`. Three of five checks failed:

| Check | Verdict | Evidence |
|---|---|---|
| Service state | FAIL | `systemctl is-active nginx = inactive` |
| Config integrity | PASS | `sudo nginx -t: syntax ok, test successful` |
| Port 80 listener | FAIL | `no process is listening on :80` |
| HTTP reply | FAIL | `curl http://127.0.0.1/ returned 000` |
| Static content | PASS | `/var/www/html/index.html present, 20798 bytes` |

The two PASSes matter as much as the three FAILs. They are what localised the fault.

## 3. Most Likely Cause

The Nginx process was not running.

The three failures are one fault, not three. They form a causal chain downstream of a stopped service: no process means nothing binds the socket, which means the port check fails, which means the HTTP request has nothing to connect to. `curl` returning `000` rather than `500` or `404` is the detail that proves this. `000` is curl's code for no connection established at all, not a server-side error.

Config integrity passing ruled out a broken config file. Static content passing ruled out missing content. That left the service itself.

The triage evidence could not establish *why* the service was inactive. A clean administrative stop, a crash, and an OOM kill all present identically to `systemctl is-active`. Distinguishing them requires `journalctl -u nginx`, which this triage did not collect, so no claim was made about the cause of the stop.

## 4. Human-Approved Recovery Action

Claude analysed the evidence and suggested exactly one command, marked FOR THE HUMAN TO RUN:

```bash
sudo systemctl start nginx
```

I read the analysis, agreed with it, and executed that command myself at 20:46:18.

Claude did not run it, and was not permitted to. The `/linux-triage` skill is declared with `allowed-tools: Bash, Read, Grep` and no Write, and CLAUDE.md forbids any state-changing command.

## 5. Verification

Recovery was not claimed on the strength of the command appearing to work. A second triage run at 20:54:22 produced `reports/recovery-report.txt`:

```
[PASS] Service state    systemctl is-active nginx = active
[PASS] Config integrity sudo nginx -t: syntax ok, test successful
[PASS] Port 80 listener nginx is LISTEN on :80
[PASS] HTTP reply       curl http://127.0.0.1/ returned 200
[PASS] Static content   /var/www/html/index.html present, 20798 bytes
 Summary: 5 PASS, 0 WARN, 0 FAIL (of 5 checks)
 Overall : HEALTHY
```

Exit code 0. The same five checks that reported the outage reported the recovery, which is what makes the comparison meaningful.

## 6. Safety Decision

The agent gathered and analysed. It did not act.

This is not ceremony. An agent that restarts a failed service destroys the evidence of why it failed. The restart succeeds, the alert clears, and the underlying cause, a full disk, an OOM kill, a config that will fail on the next boot, survives untouched to recur at a worse time. Automated recovery trades diagnosis for uptime, and that trade should be made deliberately by a human who understands what is being given up.

The technical enforcement matters more than the instruction. `allowed-tools: Bash, Read, Grep` means the skill cannot write a file even if it decided to. `disable-model-invocation: true` means it only runs when I invoke it, never because a model decided a conversation looked relevant. Rules written in prose are a request. Tool restrictions are a constraint.

Worth noting honestly: Bash is not read-only in principle. `sudo systemctl start nginx` is itself a Bash command. The safety here rests on CLAUDE.md's explicit prohibition rather than on the tool list alone, and Claude respected it across three separate invocations, including one where the fix was obvious and a single command away.

## 7. Agentic Loop Mapping

| Phase | Who | What happened |
|---|---|---|
| **GATHER** | Bash | `linux-triage.sh` ran five deterministic read-only checks and wrote a timestamped report. No interpretation. Same inputs, same output. |
| **ANALYSE** | Claude | Read the report, named the causal chain, cited the specific lines, ruled out config and content using the two PASSes, stated the limit of the evidence, and suggested one command. |
| **HUMAN ACT** | Me | Read the analysis, agreed with it, ran `sudo systemctl start nginx`. |
| **VERIFY** | Bash, then me | Second triage run. 5 PASS, exit 0. Only that report established recovery. |

The division is the point. Bash is deterministic and cannot be persuaded. Claude is good at reading evidence and should not be trusted with a restart. I am the only one accountable for what changes.

---

## Observation outside the graded checks

The root filesystem sat at **91% used, 667M free of 6.8G**, throughout this incident. It did not cause the outage and it is not one of the five checks. Claude flagged it on every invocation as context rather than folding it into the verdict, which is the correct handling: a real signal, but not this signal.

For reference, the same box measured 79% earlier the same day. Installing Claude Code and cloning the site consumed 11 percentage points in about three hours, which is exactly the trajectory my Assignment 3 answer warned about.
