#!/usr/bin/env bash
# Builds inventory.ini from Terraform outputs so IPs are never typed by hand.
# Author: Oluwagbade Odimayo
set -euo pipefail
cd "$(dirname "$0")"

ips=$(terraform -chdir=../terraform output -json public_ips)
roles=$(terraform -chdir=../terraform output -json servers_by_role)

{
  echo "# Generated from Terraform outputs by gen-inventory.sh (Oluwagbade Odimayo)"
  echo "# Groups follow each server's role: web, app, db"
  echo
  for role in web app db; do
    echo "[$role]"
    for host in $(jq -r --arg r "$role" '.[$r][]?' <<<"$roles"); do
      echo "$host ansible_host=$(jq -r --arg h "$host" '.[$h]' <<<"$ips")"
    done
    echo
  done
  echo "[all:vars]"
  echo "ansible_user=ubuntu"
  echo "ansible_ssh_private_key_file=~/.ssh/id_ed25519"
  echo "ansible_python_interpreter=/usr/bin/python3"
} > inventory.ini

echo "inventory.ini written:"
cat inventory.ini
