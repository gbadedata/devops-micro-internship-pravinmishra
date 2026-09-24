#!/bin/bash
set -euo pipefail
export HOME=/root
export DEBIAN_FRONTEND=noninteractive

HOSTNAME="oluwagbade-odimayo-app-${hostname_key}"
hostnamectl set-hostname "$HOSTNAME"
echo "127.0.1.1 $HOSTNAME" >> /etc/hosts
echo "preserve_hostname: true" > /etc/cloud/cloud.cfg.d/99-preserve-hostname.cfg

apt-get update -y
apt-get install -y git curl unzip nodejs npm

# AWS CLI v2 via the official installer (the awscli apt package isn't in
# Ubuntu 24.04's main archive; snapd may not be ready this early in boot).
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/awscliv2.zip /tmp/aws

id -u appuser &>/dev/null || useradd --system --create-home --shell /usr/sbin/nologin appuser

APP_DIR=/opt/book-review-app
rm -rf "$APP_DIR"
git clone "${repo_url}" "$APP_DIR"
cd "$APP_DIR"
git checkout "${repo_ref}"

cd "$APP_DIR/backend"
npm ci --omit=dev

# Secrets: fetched at boot by the app role; never echoed; no set -x.
DB_PASS=$(/usr/local/bin/aws ssm get-parameter --name "${db_password_parameter_name}" --with-decryption --query Parameter.Value --output text --region "${aws_region}")
JWT_SECRET=$(/usr/local/bin/aws ssm get-parameter --name "${jwt_secret_parameter_name}" --with-decryption --query Parameter.Value --output text --region "${aws_region}")

# umask scoped to a subshell; values single-quoted so dotenv keeps
# characters such as '#' (dotenv stops an unquoted value at '#').
(
  umask 077
  cat > "$APP_DIR/backend/.env" <<ENV_EOF
PORT=3001
DB_HOST=${db_primary_address}
DB_NAME=${db_name}
DB_USER=${db_username}
DB_PASS='$DB_PASS'
JWT_SECRET='$JWT_SECRET'
ALLOWED_ORIGINS=http://${public_alb_dns_name}
ENV_EOF
)
unset DB_PASS JWT_SECRET

chown -R appuser:appuser "$APP_DIR"
chmod 600 "$APP_DIR/backend/.env"

cat >/etc/systemd/system/bookreview-app.service <<'EOF'
[Unit]
Description=Book Review Backend (Express)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/book-review-app/backend
ExecStart=/usr/bin/node src/server.js
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now bookreview-app.service

touch /opt/book-review-app/.app-bootstrap-complete
