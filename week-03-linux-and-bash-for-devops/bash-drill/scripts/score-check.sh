#!/bin/bash
# score-check.sh - if-else decision making
# Oluwagbade Odimayo | DMI Cohort 3 | Group 3 | Week 3

score=55
pass_mark=70

echo "Assessment check for Oluwagbade Odimayo"
echo "Score     : $score"
echo "Pass mark : $pass_mark"

if [ "$score" -ge "$pass_mark" ]; then
    echo "Result: Pass"
else
    echo "Result: Retry"
fi
