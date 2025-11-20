# SSL & Domain Setup Checklist

## 📋 Pre-Deployment Checklist

Before running the SSL setup, ensure these are complete:

### ✅ Completed
- [x] Application built and tested
- [x] Server running on port 3104
- [x] All files created successfully
- [x] Dependencies installed
- [x] Configuration scripts ready

### ⏳ Pending (Your Action Required)

- [ ] DNS A record configured for `exchange.matrixlab.work`
- [ ] DNS propagation verified (wait 5-10 minutes after DNS change)
- [ ] Email address ready for Let's Encrypt notifications
- [ ] Server has internet access
- [ ] Ports 80 and 443 are available

---

## 🔍 Step-by-Step Verification

### Step 1: Check Your Server IP

```bash
curl ifconfig.me
```

**Expected Output:** Your server's public IP address (e.g., 123.45.67.89)

**Action:** Note this IP address for DNS configuration

---

### Step 2: Configure DNS

Go to your DNS provider (where you manage matrixlab.work) and add:

```
Type: A
Name: exchange
Value: [Your Server IP from Step 1]
TTL: 3600 (or Auto)
```

**Example:**
```
A    exchange    123.45.67.89    3600
```

---

### Step 3: Verify DNS Propagation

Wait 5-10 minutes, then check:

```bash
nslookup exchange.matrixlab.work
```

**Expected Output:**
```
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
Name:   exchange.matrixlab.work
Address: [Your Server IP]
```

**If it doesn't work:**
- Wait longer (DNS can take up to 24 hours)
- Check your DNS provider's interface
- Try: `nslookup exchange.matrixlab.work 8.8.8.8`

---

### Step 4: Check Required Ports

```bash
# Check if ports 80 and 443 are free
sudo netstat -tuln | grep -E ':(80|443)'
```

**Expected Output:** Empty (no output means ports are free)

**If ports are in use:**
```bash
# Check what's using them
sudo lsof -i :80
sudo lsof -i :443

# Stop conflicting services if needed
sudo systemctl stop apache2  # if Apache is running
```

---

### Step 5: Install Nginx and Certbot

The setup script will do this, but you can check:

```bash
# Check if Nginx is installed
nginx -v

# Check if Certbot is installed
certbot --version
```

**If not installed, the script will install them automatically**

---

## 🚀 Running the Setup

### Option A: Automatic Setup (Recommended)

```bash
cd /home/ubuntu/yz/Web3/网站test1

# 1. Setup systemd service (optional but recommended)
sudo ./setup-systemd.sh

# 2. Setup Nginx and prepare for SSL
sudo ./setup-ssl.sh

# 3. Obtain SSL certificate
sudo certbot --nginx -d exchange.matrixlab.work --email YOUR_EMAIL@example.com --agree-tos --no-eff-email
```

**Replace `YOUR_EMAIL@example.com` with your actual email!**

---

### Option B: Manual Setup

If you prefer to do it manually:

#### 1. Install Nginx
```bash
sudo apt update
sudo apt install -y nginx
```

#### 2. Install Certbot
```bash
sudo apt install -y certbot python3-certbot-nginx
```

#### 3. Create Nginx Configuration
```bash
sudo nano /etc/nginx/sites-available/exchange.matrixlab.work
```

Paste the configuration from `setup-ssl.sh` (lines 35-80)

#### 4. Enable Site
```bash
sudo ln -s /etc/nginx/sites-available/exchange.matrixlab.work /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### 5. Obtain Certificate
```bash
sudo certbot --nginx -d exchange.matrixlab.work --email YOUR_EMAIL@example.com --agree-tos
```

---

## ✅ Post-Setup Verification

### 1. Check Nginx Status
```bash
sudo systemctl status nginx
```

**Expected:** `active (running)`

### 2. Check SSL Certificate
```bash
sudo certbot certificates
```

**Expected:** Shows certificate for exchange.matrixlab.work

### 3. Test HTTPS Access
```bash
curl -I https://exchange.matrixlab.work
```

**Expected:** `HTTP/2 200`

### 4. Test in Browser

Open: `https://exchange.matrixlab.work`

**Expected:**
- ✅ Secure padlock icon in address bar
- ✅ Landing page loads
- ✅ Scroll animations work
- ✅ VPN detection runs
- ✅ MetaMask button appears

---

## 🔒 Security Verification

### Check SSL Grade

Visit: https://www.ssllabs.com/ssltest/analyze.html?d=exchange.matrixlab.work

**Target Grade:** A or A+

### Check Security Headers

```bash
curl -I https://exchange.matrixlab.work
```

**Should include:**
- `Strict-Transport-Security`
- `X-Frame-Options`
- `X-Content-Type-Options`
- `X-XSS-Protection`

---

## 🔄 Certificate Auto-Renewal

Certbot automatically sets up renewal. Verify:

```bash
# Test renewal process
sudo certbot renew --dry-run
```

**Expected:** `Congratulations, all simulated renewals succeeded`

### Manual Renewal (if needed)
```bash
sudo certbot renew
sudo systemctl reload nginx
```

---

## 🐛 Troubleshooting

### Issue: DNS not resolving

**Solution:**
```bash
# Check DNS from different servers
dig exchange.matrixlab.work @8.8.8.8
dig exchange.matrixlab.work @1.1.1.1

# Wait longer (up to 24 hours for global propagation)
```

### Issue: Port 80 already in use

**Solution:**
```bash
# Find what's using it
sudo lsof -i :80

# Stop the service
sudo systemctl stop [service-name]

# Or change the conflicting service's port
```

### Issue: Certbot fails with "Connection refused"

**Solution:**
```bash
# Ensure Nginx is running
sudo systemctl start nginx

# Check firewall
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Try again
sudo certbot --nginx -d exchange.matrixlab.work
```

### Issue: Certificate obtained but HTTPS doesn't work

**Solution:**
```bash
# Check Nginx configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log
```

### Issue: "Too many certificates already issued"

**Solution:**
Let's Encrypt has rate limits (5 certificates per week per domain)
- Wait a week, or
- Use staging environment for testing:
```bash
sudo certbot --nginx -d exchange.matrixlab.work --staging
```

---

## 📊 Final Checklist

After completing setup, verify:

- [ ] DNS resolves to correct IP
- [ ] Nginx is running
- [ ] SSL certificate is installed
- [ ] HTTPS works in browser
- [ ] HTTP redirects to HTTPS
- [ ] Security headers are present
- [ ] Application loads correctly
- [ ] VPN detection works
- [ ] MetaMask connection works
- [ ] All dashboard links work
- [ ] Mobile responsive design works
- [ ] Auto-renewal is configured

---

## 🎉 Success Indicators

You'll know everything is working when:

1. ✅ Browser shows padlock icon
2. ✅ URL shows `https://exchange.matrixlab.work`
3. ✅ No certificate warnings
4. ✅ Landing page animations work
5. ✅ VPN detection runs
6. ✅ MetaMask connects successfully
7. ✅ Dashboard appears after login
8. ✅ All links work correctly

---

## 📞 Need Help?

### Check Logs

**Application:**
```bash
sudo journalctl -u matrixlab-exchange -f
```

**Nginx:**
```bash
sudo tail -f /var/log/nginx/matrixlab-exchange-error.log
```

**Certbot:**
```bash
sudo tail -f /var/log/letsencrypt/letsencrypt.log
```

### Common Commands

```bash
# Restart everything
sudo systemctl restart matrixlab-exchange
sudo systemctl restart nginx

# Check status
sudo systemctl status matrixlab-exchange
sudo systemctl status nginx

# Test configuration
sudo nginx -t

# Renew certificate
sudo certbot renew --force-renewal
```

---

## 📝 Quick Reference

### Important Files
- Nginx config: `/etc/nginx/sites-available/exchange.matrixlab.work`
- SSL cert: `/etc/letsencrypt/live/exchange.matrixlab.work/`
- App directory: `/home/ubuntu/yz/Web3/网站test1/`

### Important Commands
```bash
# Start app
sudo systemctl start matrixlab-exchange

# Reload Nginx
sudo systemctl reload nginx

# Renew certificate
sudo certbot renew

# View logs
sudo journalctl -u matrixlab-exchange -f
```

---

**Ready to deploy? Start with Step 1! 🚀**
