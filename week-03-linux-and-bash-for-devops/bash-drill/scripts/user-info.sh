#!/bin/bash
# user-info.sh - storing and displaying values with variables
# Oluwagbade Odimayo | DMI Cohort 3 | Group 3 | Week 3

full_name="Oluwagbade Odimayo"
cohort="DMI Cohort 3"
group="Group 3"
week="Week 3"
current_user=$(whoami)
host_name=$(hostname)

echo "Full name    : $full_name"
echo "Cohort       : $cohort"
echo "Group        : $group"
echo "Week         : $week"
echo "Linux user   : $current_user"
echo "Hostname     : $host_name"
echo "Home dir     : $HOME"
echo "Shell in use : $SHELL"
