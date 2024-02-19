#!/bin/bash

# Install Nginx
apt-get update
apt-get install -y nginx net-tools

# Generate self-signed SSL certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=US/ST=Florida/L=Miami/O=trace-org/OU=trace/CN=${domain}"

# Configure Nginx to use the SSL certificate and serve a test page
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 443 ssl default_server;

    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

    server_name _;

    location / {
        root /var/www/html;
        index index.nginx-debian.html;
    }
}
EOF

# Restart Nginx to apply changes
systemctl restart nginx
