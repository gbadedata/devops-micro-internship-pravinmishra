#!/bin/bash
# cloud-init.sh: automated deployment of my-react-app on Ubuntu 24.04 with Nginx.
# Passed to the VM by Terraform (custom_data) and run once as root at first boot.
# Contains no secrets. Full log: /var/log/react-deploy.log
set -euxo pipefail
exec > >(tee -a /var/log/react-deploy.log) 2>&1

DEPLOYED_BY="Oluwagbade Odimayo"
DEPLOY_DATE="$(date +%d/%m/%Y)"
APP_DIR="/opt/my-react-app"
export HOME=/root
export DEBIAN_FRONTEND=noninteractive

# 1. Swap: the React build can exceed the 1 GB of RAM on a Standard_B1s VM
if ! swapon --show | grep -q /swapfile; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
fi

# 2. Node.js, npm, Nginx and Git (Ubuntu 24.04 ships Node.js 18, matching the repo's CI)
apt-get update -y
apt-get install -y nodejs npm nginx git
systemctl enable --now nginx

# 3. Clone the app and set my name and today's date in App.js
rm -rf "$APP_DIR"
git clone https://github.com/pravinmishraaws/my-react-app.git "$APP_DIR"
cd "$APP_DIR"
sed -i "s|<strong>Your Full Name</strong>|<strong>${DEPLOYED_BY}</strong>|; s|<strong>DD/MM/YYYY</strong>|<strong>${DEPLOY_DATE}</strong>|" src/App.js
grep -q "$DEPLOYED_BY" src/App.js

# 4. Install exact dependencies from the lockfile, then build
npm ci --no-audit --no-fund
npm run build

# 5. Publish the build to the Nginx web root
rm -rf /var/www/html/*
cp -r build/* /var/www/html/
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# 6. Nginx config for a single-page app
cat > /etc/nginx/sites-available/default << 'NGINX'
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri /index.html;
    }

    error_page 404 /index.html;
}
NGINX
nginx -t
systemctl restart nginx

# 7. Completion marker used to verify the deployment
echo "React deployment completed at $(date -u '+%Y-%m-%d %H:%M:%S UTC') by ${DEPLOYED_BY}" | tee /var/log/react-deploy.done
