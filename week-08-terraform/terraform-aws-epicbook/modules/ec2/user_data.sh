#!/bin/bash
# user_data.sh: prepares the EpicBook app server on Ubuntu 24.04.
# Installs software only. It contains no database credentials or other secrets;
# the app is connected to RDS later, over SSH.
# Log: /var/log/epicbook-setup.log
set -euxo pipefail
exec > >(tee -a /var/log/epicbook-setup.log) 2>&1
export DEBIAN_FRONTEND=noninteractive

hostnamectl set-hostname oluwagbade-odimayo

apt-get update -y
apt-get install -y nodejs npm nginx git mysql-client
systemctl enable --now nginx

node -v
npm -v
nginx -v
mysql --version

echo "EpicBook server setup completed at $(date -u '+%Y-%m-%d %H:%M:%S UTC') by Oluwagbade Odimayo" | tee /var/log/epicbook-setup.done
