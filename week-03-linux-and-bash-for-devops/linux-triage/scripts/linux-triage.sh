#!/bin/bash
#
# linux-triage.sh — read-only health triage for Nginx + static site on port 80
#
# Analyst : Oluwagbade Odimayo
# Program : DMI Cohort 3 | Group 3 | Week 3
# Host    : oluwagbade-odimayo (Ubuntu 24.04, AWS EC2 t3.micro, eu-west-2)
#
# Role of this script: GATHER only. It collects five pieces of health evidence
# and writes a timestamped report to reports/. It interprets nothing and changes
# nothing. Every command below is read-only; it cannot alter what a subsequent
# run would observe. Analysis is Claude's job; recovery is the human's job.
#
# The five graded checks:
#   1. Service state       systemctl is-active nginx           -> FAIL if not active
#   2. Config integrity    sudo nginx -t                       -> WARN if test fails
#   3. Port 80 listener    sudo ss -ltnp 'sport = :80'         -> FAIL if not nginx
#   4. HTTP reply          curl http://127.0.0.1/              -> FAIL if not 200
#   5. Static content      test -s /var/www/html/index.html    -> FAIL if missing
#
# Observed context (NOT a graded check): at build time `df -h /` reported the
# root filesystem at 91% used (667M free of 6.8G). This is a live WARN-worthy
# condition worth watching — if / reaches 100%, Nginx cannot write logs or temp
# files and serving degrades. It is deliberately excluded from the verdict so the
# five graded checks stay focused on Nginx + the static site. Raise it in ANALYSE.
#
# Exit codes: 0 = HEALTHY (all PASS) | 1 = any FAIL | 2 = WARN present, no FAIL

# --- Locations -------------------------------------------------------------
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_DIR=$(dirname "$SCRIPT_DIR")
REPORT_DIR="$PROJECT_DIR/reports"
TS=$(date +%Y%m%d-%H%M%S)
REPORT="$REPORT_DIR/triage-$TS.txt"

mkdir -p "$REPORT_DIR"

# Emit a line to both the report file and the terminal.
emit() {
    printf '%s\n' "$*" | tee -a "$REPORT"
}

# --- Check functions -------------------------------------------------------
# Each function prints exactly one line: VERDICT|Label|Evidence
# VERDICT is one of PASS / WARN / FAIL. Every check is read-only.

# 1. Is the nginx unit running right now? No process -> total outage.
check_service() {
    local state
    state=$(systemctl is-active nginx 2>/dev/null)
    if [ "$state" = "active" ]; then
        echo "PASS|Service state|systemctl is-active nginx = active"
    else
        echo "FAIL|Service state|systemctl is-active nginx = ${state:-unknown}"
    fi
}

# 2. Does the on-disk config still pass? Failure is latent (running nginx keeps
#    serving its loaded config), so this is WARN, not FAIL. Needs root.
check_config() {
    local out rc
    out=$(sudo -n nginx -t 2>&1)
    rc=$?
    if [ "$rc" -eq 0 ]; then
        echo "PASS|Config integrity|sudo nginx -t: syntax ok, test successful"
    else
        echo "WARN|Config integrity|sudo nginx -t exited $rc: $(echo "$out" | tr '\n' ' ')"
    fi
}

# 3. Is something listening on :80, and is it nginx? Needs root to see the owner.
check_port() {
    local out
    out=$(sudo -n ss -ltnpH 'sport = :80' 2>/dev/null)
    if [ -z "$out" ]; then
        echo "FAIL|Port 80 listener|no process is listening on :80"
    elif echo "$out" | grep -q '"nginx"'; then
        echo "PASS|Port 80 listener|nginx is LISTEN on :80"
    else
        echo "FAIL|Port 80 listener|:80 held by non-nginx process: $(echo "$out" | tr '\n' ' ')"
    fi
}

# 4. End-to-end proof: does a real HTTP request come back 200? This exercises the
#    whole chain (process, port, config, content) as a user would see it.
check_http() {
    local code
    code=$(curl -o /dev/null -s -w '%{http_code}' --max-time 5 http://127.0.0.1/ 2>/dev/null)
    if [ "$code" = "200" ]; then
        echo "PASS|HTTP reply|curl http://127.0.0.1/ returned 200"
    else
        echo "FAIL|HTTP reply|curl http://127.0.0.1/ returned ${code:-000}"
    fi
}

# 5. Is the file the site is built to serve actually present and non-empty?
check_content() {
    local f="/var/www/html/index.html" sz
    if [ -s "$f" ]; then
        sz=$(stat -c %s "$f" 2>/dev/null)
        echo "PASS|Static content|$f present, ${sz} bytes"
    else
        echo "FAIL|Static content|$f missing or empty"
    fi
}

# --- The five checks, as an array consumed by one loop ---------------------
CHECKS=(check_service check_config check_port check_http check_content)

# --- Report header ---------------------------------------------------------
emit "=========================================================="
emit " Linux Triage Report — Nginx + static site on port 80"
emit "=========================================================="
emit " Analyst   : Oluwagbade Odimayo"
emit " Program   : DMI Cohort 3 | Group 3 | Week 3"
emit " Host      : $(hostname)"
emit " Timestamp : $TS"
emit " Report    : $REPORT"
emit "----------------------------------------------------------"

# --- Run the checks --------------------------------------------------------
pass=0
warn=0
fail=0

for chk in "${CHECKS[@]}"; do
    line=$("$chk")
    verdict=${line%%|*}
    rest=${line#*|}
    label=${rest%%|*}
    evidence=${rest#*|}

    emit "$(printf '[%-4s] %-16s %s' "$verdict" "$label" "$evidence")"

    case "$verdict" in
        PASS) pass=$((pass + 1)) ;;
        WARN) warn=$((warn + 1)) ;;
        FAIL) fail=$((fail + 1)) ;;
    esac
done

# --- Summary and verdict ---------------------------------------------------
emit "----------------------------------------------------------"
emit "$(printf ' Summary: %d PASS, %d WARN, %d FAIL (of %d checks)' \
    "$pass" "$warn" "$fail" "${#CHECKS[@]}")"

if [ "$fail" -gt 0 ]; then
    overall="FAIL"
    rc=1
elif [ "$warn" -gt 0 ]; then
    overall="WARN"
    rc=2
else
    overall="HEALTHY"
    rc=0
fi

emit " Overall : $overall"
emit "=========================================================="

exit "$rc"
