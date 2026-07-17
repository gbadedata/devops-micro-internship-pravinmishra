#!/bin/bash
# file-check.sh - file and directory conditionals
# Oluwagbade Odimayo | DMI Cohort 3 | Group 3 | Week 3

target_dir="../test-folder"
target_file="../test-folder/deploy-manifest.txt"
missing_file="../test-folder/does-not-exist.txt"

echo "File validation run by Oluwagbade Odimayo"
echo "-----------------------------------------"

if [ -d "$target_dir" ]; then
    echo "[ OK   ] Directory found : $target_dir"
else
    echo "[ FAIL ] Directory missing: $target_dir"
fi

if [ -f "$target_file" ]; then
    echo "[ OK   ] File found      : $target_file"
    echo "         Contents        : $(cat "$target_file")"
else
    echo "[ FAIL ] File missing    : $target_file"
fi

if [ -f "$missing_file" ]; then
    echo "[ OK   ] File found      : $missing_file"
else
    echo "[ FAIL ] File missing    : $missing_file  (expected, proves the else branch runs)"
fi
