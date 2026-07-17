#!/bin/bash
# tools-checklist.sh - arrays and loops
# Oluwagbade Odimayo | DMI Cohort 3 | Group 3 | Week 3

tools=("bash" "git" "nginx" "node" "npm" "curl")

echo "Week 3 tools checklist for Oluwagbade Odimayo"
echo "Tools tracked: ${#tools[@]}"
echo "----------------------------------------"

for tool in "${tools[@]}"; do
    if command -v "$tool" > /dev/null 2>&1; then
        echo "[ INSTALLED ] $tool"
    else
        echo "[  MISSING  ] $tool"
    fi
done
