#!/bin/bash
# final-automation.sh - variables, arrays, loops, conditionals, files and functions
# Oluwagbade Odimayo | DMI Cohort 3 | Group 3 | Week 3

owner="Oluwagbade Odimayo"
cohort="DMI Cohort 3"
evidence_dir="../test-folder"
checks=("bash" "git" "nginx" "curl")
pass_count=0
fail_count=0

print_header() {
    echo "================================================"
    echo " Week 3 automation summary"
    echo " Owner : $owner"
    echo " Cohort: $cohort"
    echo " Host  : $(hostname)"
    echo " Date  : $(date '+%d/%m/%Y %H:%M:%S')"
    echo "================================================"
}

check_tool() {
    local tool="$1"
    if command -v "$tool" > /dev/null 2>&1; then
        echo "[ PASS ] $tool -> $(command -v "$tool")"
        return 0
    else
        echo "[ FAIL ] $tool not found"
        return 1
    fi
}

check_evidence() {
    if [ -d "$evidence_dir" ]; then
        echo "[ PASS ] Evidence directory present: $evidence_dir"
        return 0
    else
        echo "[ FAIL ] Evidence directory missing: $evidence_dir"
        return 1
    fi
}

print_summary() {
    echo "------------------------------------------------"
    echo " Passed: $pass_count"
    echo " Failed: $fail_count"
    if [ "$fail_count" -eq 0 ]; then
        echo " Overall status: HEALTHY"
        return 0
    else
        echo " Overall status: ATTENTION NEEDED"
        return 1
    fi
}

print_header

for tool in "${checks[@]}"; do
    if check_tool "$tool"; then
        pass_count=$((pass_count + 1))
    else
        fail_count=$((fail_count + 1))
    fi
done

if check_evidence; then
    pass_count=$((pass_count + 1))
else
    fail_count=$((fail_count + 1))
fi

print_summary
exit $?
