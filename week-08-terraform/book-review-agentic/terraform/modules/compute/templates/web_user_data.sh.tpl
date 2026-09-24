#!/bin/bash
set -euo pipefail
export HOME=/root
export DEBIAN_FRONTEND=noninteractive

HOSTNAME="oluwagbade-odimayo-web-${hostname_key}"
hostnamectl set-hostname "$HOSTNAME"
echo "127.0.1.1 $HOSTNAME" >> /etc/hosts
echo "preserve_hostname: true" > /etc/cloud/cloud.cfg.d/99-preserve-hostname.cfg

apt-get update -y
apt-get install -y nginx git curl nodejs npm

# 2 GB swap: next build can exceed t3.small's 2 GB RAM.
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

id -u appuser &>/dev/null || useradd --system --create-home --shell /usr/sbin/nologin appuser

APP_DIR=/opt/book-review-app
rm -rf "$APP_DIR"
git clone "${repo_url}" "$APP_DIR"
cd "$APP_DIR"
git checkout "${repo_ref}"

cd "$APP_DIR/frontend"
export NEXT_PUBLIC_API_URL=/api
npm ci
npm run build

chown -R appuser:appuser "$APP_DIR"

cat >/etc/systemd/system/bookreview-web.service <<'EOF'
[Unit]
Description=Book Review Frontend (Next.js)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/book-review-app/frontend
Environment=PORT=3000
Environment=NODE_ENV=production
ExecStart=/usr/bin/npm start
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now bookreview-web.service

rm -f /etc/nginx/sites-enabled/default

cat >/etc/nginx/sites-available/bookreview <<'NGINX_CONF'
resolver 169.254.169.253 valid=30s;

server {
    listen 80 default_server;
    server_name _;

    location /api/ {
        set $api_upstream http://${internal_alb_dns_name};
        proxy_pass $api_upstream;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX_CONF

ln -sf /etc/nginx/sites-available/bookreview /etc/nginx/sites-enabled/bookreview
nginx -t
systemctl restart nginx
systemctl enable nginx

touch /opt/book-review-app/.web-bootstrap-complete
