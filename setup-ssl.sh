#!/bin/bash

# MatrixLab Exchange - SSL and Domain Configuration Script
# Domain: exchange.matrixlab.work
# Port: 3104

echo "==================================="
echo "MatrixLab Exchange SSL Setup"
echo "==================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Variables
DOMAIN="exchange.matrixlab.work"
EMAIL="admin@matrixlab.work"  # Change this to your email
APP_PORT=3104
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
NGINX_ENABLED="/etc/nginx/sites-enabled/$DOMAIN"

echo "Domain: $DOMAIN"
echo "App Port: $APP_PORT"
echo ""

# Check if nginx is installed
if ! command -v nginx &> /dev/null; then
    echo "Installing Nginx..."
    apt update
    apt install -y nginx
fi

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "Installing Certbot..."
    apt update
    apt install -y certbot python3-certbot-nginx
fi

# Create Nginx configuration
echo "Creating Nginx configuration..."
cat > $NGINX_CONF << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name exchange.matrixlab.work;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name exchange.matrixlab.work;

    # SSL certificates (will be configured by certbot)
    ssl_certificate /etc/letsencrypt/live/exchange.matrixlab.work/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/exchange.matrixlab.work/privkey.pem;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Proxy settings
    location / {
        proxy_pass http://localhost:3104;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Logging
    access_log /var/log/nginx/matrixlab-exchange-access.log;
    error_log /var/log/nginx/matrixlab-exchange-error.log;
}
EOF

# Enable the site
echo "Enabling Nginx site..."
ln -sf $NGINX_CONF $NGINX_ENABLED

# Test Nginx configuration
echo "Testing Nginx configuration..."
nginx -t

if [ $? -ne 0 ]; then
    echo "Nginx configuration test failed!"
    exit 1
fi

# Reload Nginx
echo "Reloading Nginx..."
systemctl reload nginx

echo ""
echo "==================================="
echo "Next Steps:"
echo "==================================="
echo ""
echo "1. Make sure your DNS A record points to this server's IP:"
echo "   exchange.matrixlab.work -> $(curl -s ifconfig.me)"
echo ""
echo "2. Run the following command to obtain SSL certificate:"
echo "   sudo certbot --nginx -d $DOMAIN --email $EMAIL --agree-tos --no-eff-email"
echo ""
echo "3. Certbot will automatically configure SSL and set up auto-renewal"
echo ""
echo "4. After SSL is configured, your site will be available at:"
echo "   https://$DOMAIN"
echo ""
echo "==================================="
