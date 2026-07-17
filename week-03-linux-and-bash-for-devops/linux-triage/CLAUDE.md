# Linux Triage: Project Context for Claude

Owner: Oluwagbade Odimayo | DMI Cohort 3 | Group 3 | Week 3
Host: oluwagbade-odimayo (Ubuntu 24.04, AWS EC2 t3.micro, eu-west-2)

## Project Overview

This project performs read-only health triage on a live Ubuntu web server.
The server runs Nginx 1.24.0 serving a static site from /var/www/html on port 80.
The site is publicly reachable at http://3.8.142.4.

The single deliverable is `scripts/linux-triage.sh`: one Bash script that gathers
five pieces of health evidence and writes a timestamped report to `reports/`.

Bash gathers the evidence. Claude interprets it. A human decides what to do about it.
Those three roles do not overlap.

## Incident Workflow

Every incident follows the Agentic Loop, in this order, without skipping:

1. GATHER   Bash runs `linux-triage.sh`. It collects evidence and writes a report.
            Deterministic. Same inputs, same output. No interpretation.
2. ANALYSE  Claude reads the report and explains what the evidence shows.
            Claude names the most likely cause and cites the specific lines
            that support it. Claude suggests one recovery command.
3. HUMAN ACT The human reads the analysis and runs the recovery command.
            Claude never runs it.
4. VERIFY   The human re-runs the triage. Recovery is not claimed until a second
            report shows no FAIL results.

## Safety Rules

1. Claude MUST NOT execute any command that changes system state. That includes
   systemctl start/stop/restart/reload, any write to /etc or /var/www, rm, mv,
   chmod, chown, apt, and any redirect that creates or truncates a file.
2. Claude MUST NOT run recovery commands. Claude suggests them as text only.
   The human executes them. This is not a formality: an agent that restarts a
   failed service destroys the evidence of why it failed.
3. Claude MUST NOT diagnose without evidence. Every conclusion must cite a
   specific line from a report or a command output. "Nginx is probably down"
   is not acceptable. "systemctl is-active returned inactive" is.
4. Claude MUST NOT invent evidence. If a check did not run, say so. If a report
   is missing a section, say so. Absence of data is a finding, not a gap to fill.
5. Claude MAY read files, run read-only commands, and grep. Read-only means the
   command cannot change what a subsequent run would observe.

## Output Rules

1. Lead with the evidence, then the conclusion. Not the reverse.
2. Quote the exact line that supports each claim.
3. State confidence plainly. If the evidence supports two causes, say both.
4. End with exactly one suggested recovery command, in a code block, marked
   clearly as FOR THE HUMAN TO RUN.
5. Never claim recovery. Only a second triage run can establish that.
