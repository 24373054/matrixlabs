# MatrixLab Exchange - Deployment Guide

## 🚀 Quick Start

The application is currently running on port 3104. Follow these steps to configure SSL and domain.

## 📋 Prerequisites

1. **DNS Configuration**: Ensure `exchange.matrixlab.work` points to your server's IP address
   ```bash
   # Check your server's public IP
   curl ifconfig.me
   ```

2. **Domain DNS Record**: Add an A record in your DNS provider:
   ```
   Type: A
   Name: exchange
   Value: [Your Server IP]
   TTL: 3600
   ```

## 🔧 Step-by-Step Deployment

### Step 1: Setup Systemd Service (Optional but Recommended)

This ensures the app runs automatically on server restart:

```bash
cd /home/ubuntu/yz/Web3/网站test1
sudo ./setup-systemd.sh
```

This will:
- Create a systemd service
- Enable auto-start on boot
- Start the application

### Step 2: Configure Nginx and SSL

```bash
sudo ./setup-ssl.sh
```

This will:
- Install Nginx and Certbot (if not already installed)
- Create Nginx configuration for your domain
- Set up reverse proxy from port 443 to 3104

### Step 3: Obtain SSL Certificate

After running the SSL setup script, obtain your Let's Encrypt certificate:

```bash
sudo certbot --nginx -d exchange.matrixlab.work --email your-email@example.com --agree-tos --no-eff-email
```

Replace `your-email@example.com` with your actual email address.

### Step 4: Verify Installation

1. Check if Nginx is running:
   ```bash
   sudo systemctl status nginx
   ```

2. Check if the app is running:
   ```bash
   sudo systemctl status matrixlab-exchange
   # OR if not using systemd:
   ps aux | grep node
   ```

3. Test the website:
   ```bash
   curl -I https://exchange.matrixlab.work
   ```

4. Open in browser: `https://exchange.matrixlab.work`

## 🔒 SSL Certificate Auto-Renewal

Certbot automatically sets up a cron job for certificate renewal. Verify it:

```bash
sudo certbot renew --dry-run
```

## 📊 Monitoring and Logs

### Application Logs (if using systemd)
```bash
# View real-time logs
sudo journalctl -u matrixlab-exchange -f

# View last 100 lines
sudo journalctl -u matrixlab-exchange -n 100
```

### Nginx Logs
```bash
# Access logs
sudo tail -f /var/log/nginx/matrixlab-exchange-access.log

# Error logs
sudo tail -f /var/log/nginx/matrixlab-exchange-error.log
```

### Application Logs (if running manually)
The app outputs to console. Use PM2 or systemd for persistent logging.

## 🔄 Managing the Application

### Using Systemd (Recommended)
```bash
# Start
sudo systemctl start matrixlab-exchange

# Stop
sudo systemctl stop matrixlab-exchange

# Restart
sudo systemctl restart matrixlab-exchange

# Status
sudo systemctl status matrixlab-exchange
```

### Manual Management
```bash
# Start
cd /home/ubuntu/yz/Web3/网站test1
npm start

# Stop (find process and kill)
ps aux | grep "node server.js"
kill [PID]
```

## 🛠️ Troubleshooting

### Port Already in Use
```bash
# Check what's using port 3104
sudo lsof -i :3104

# Kill the process if needed
sudo kill [PID]
```

### Nginx Configuration Issues
```bash
# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Restart Nginx
sudo systemctl restart nginx
```

### SSL Certificate Issues
```bash
# Check certificate status
sudo certbot certificates

# Renew certificate manually
sudo certbot renew

# Force renewal
sudo certbot renew --force-renewal
```

### DNS Not Resolving
```bash
# Check DNS resolution
nslookup exchange.matrixlab.work

# Check from different DNS
dig exchange.matrixlab.work @8.8.8.8
```

## 🔐 Security Checklist

- [x] VPN detection enabled
- [x] MetaMask signature authentication
- [x] HTTPS with Let's Encrypt
- [x] Security headers configured
- [x] HSTS enabled
- [ ] Firewall configured (recommended)
- [ ] Regular backups (recommended)

### Recommended Firewall Rules
```bash
# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP (for Let's Encrypt)
sudo ufw allow 80/tcp

# Allow HTTPS
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable
```

## 📱 Testing Mobile Access

1. **Desktop Browser**: Visit `https://exchange.matrixlab.work`
2. **Mobile Browser**: Same URL, should be responsive
3. **MetaMask Mobile**: 
   - Open MetaMask app
   - Go to Browser tab
   - Enter: `exchange.matrixlab.work`
   - Connect wallet and sign

## 🔄 Updating the Application

```bash
cd /home/ubuntu/yz/Web3/网站test1

# Pull latest changes (if using git)
git pull

# Install dependencies if needed
npm install

# Restart the application
sudo systemctl restart matrixlab-exchange
# OR if running manually, stop and start again
```

## 📞 Support

For issues or questions:
- Check logs first
- Verify DNS configuration
- Ensure ports are not blocked
- Check firewall rules

## 🎯 Current Status

- ✅ Application running on port 3104
- ✅ Responsive design implemented
- ✅ VPN detection active
- ✅ MetaMask integration complete
- ✅ Scroll animations working
- ⏳ SSL certificate (pending configuration)
- ⏳ Domain setup (pending DNS configuration)

## 📝 Notes

- The application uses port 3104 (3105 is available as backup)
- VPN detection uses multiple methods for accuracy
- MetaMask mobile browser is fully supported
- All animations are optimized for performance
- Design follows modern, cold-toned aesthetic (no AI-style gradients)
