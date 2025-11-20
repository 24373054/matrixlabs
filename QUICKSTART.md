# MatrixLab Exchange - Quick Start Guide

## 🎯 Current Status

✅ **Application is RUNNING on port 3104**

You can access it locally at: `http://localhost:3104`

## 🚀 Next Steps for Production

### Step 1: Configure DNS (Do this first!)

Add an A record in your DNS provider for `matrixlab.work`:

```
Type: A
Name: exchange
Value: [Your Server IP Address]
TTL: 3600
```

To find your server IP:
```bash
curl ifconfig.me
```

Wait 5-10 minutes for DNS propagation, then verify:
```bash
nslookup exchange.matrixlab.work
```

### Step 2: Setup Auto-Start (Recommended)

Choose ONE of these options:

#### Option A: Using Systemd (Recommended for production)
```bash
cd /home/ubuntu/yz/Web3/网站test1
sudo ./setup-systemd.sh
```

#### Option B: Using PM2 (Alternative)
```bash
# Install PM2 globally
npm install -g pm2

# Start the app
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup
```

### Step 3: Configure SSL Certificate

```bash
cd /home/ubuntu/yz/Web3/网站test1
sudo ./setup-ssl.sh
```

Then obtain the certificate:
```bash
sudo certbot --nginx -d exchange.matrixlab.work --email your-email@example.com --agree-tos
```

### Step 4: Access Your Site

Open in browser: `https://exchange.matrixlab.work`

## 🧪 Testing Locally

### Test the Landing Page
1. Open: `http://localhost:3104`
2. Scroll down to see animations
3. Watch text slide in from left and right
4. Notice color changes between sections

### Test VPN Detection
1. Scroll to bottom section
2. Watch the "Magic Detection" status
3. It will check your network environment
4. May require actual VPN for full testing

### Test MetaMask Connection
1. Install MetaMask browser extension
2. Click "Connect MetaMask" button
3. Approve connection in MetaMask
4. Sign the authentication message
5. Dashboard should appear with smooth fade-in

### Test Mobile
1. Open on mobile device: `http://[your-server-ip]:3104`
2. Test responsive design
3. Test MetaMask mobile browser integration

## 📱 Mobile Testing with MetaMask

### On Mobile Device:
1. Install MetaMask mobile app
2. Open MetaMask browser
3. Navigate to: `exchange.matrixlab.work` (after SSL setup)
4. Connect wallet
5. Sign message
6. Access dashboard

## 🔍 Troubleshooting

### Server Not Running?
```bash
cd /home/ubuntu/yz/Web3/网站test1
npm start
```

### Port Already in Use?
```bash
# Check what's using port 3104
sudo lsof -i :3104

# Kill the process
sudo kill [PID]

# Or use port 3105 instead
PORT=3105 npm start
```

### Can't Access from External Network?
```bash
# Check if port is open
sudo ufw status

# Allow port 3104 (if using firewall)
sudo ufw allow 3104/tcp
```

### DNS Not Working?
```bash
# Check DNS propagation
nslookup exchange.matrixlab.work

# Try with Google DNS
nslookup exchange.matrixlab.work 8.8.8.8

# Check from online tool
# Visit: https://dnschecker.org
```

## 📋 Management Commands

### Manual Start/Stop
```bash
# Start
cd /home/ubuntu/yz/Web3/网站test1
npm start

# Stop (Ctrl+C or find and kill process)
ps aux | grep "node server.js"
kill [PID]
```

### With Systemd
```bash
sudo systemctl start matrixlab-exchange
sudo systemctl stop matrixlab-exchange
sudo systemctl restart matrixlab-exchange
sudo systemctl status matrixlab-exchange
```

### With PM2
```bash
pm2 start matrixlab-exchange
pm2 stop matrixlab-exchange
pm2 restart matrixlab-exchange
pm2 status
pm2 logs matrixlab-exchange
```

## 🎨 Design Features Implemented

✅ **Landing Page**
- 5 sections with scroll animations
- Text slides from left and right
- Opacity transitions
- Color changes per section

✅ **VPN Detection**
- Multi-factor detection system
- WebRTC leak check
- Connection timing analysis
- IP reputation verification

✅ **MetaMask Integration**
- Desktop browser support
- Mobile browser support
- Signature authentication
- Account change detection

✅ **Dashboard**
- 4 navigation cards
- StableGuard (in development)
- Lab news link
- MatrixLab website link
- Developer profile link

✅ **Responsive Design**
- Mobile-first approach
- Tablet optimization
- Desktop enhancement
- Touch-friendly controls

✅ **Modern Aesthetic**
- Cold-toned color scheme
- Low contrast design
- Transparent components
- Borderless fusion style
- NO AI-style gradients

## 📞 Need Help?

### Check Logs
```bash
# If using systemd
sudo journalctl -u matrixlab-exchange -f

# If using PM2
pm2 logs matrixlab-exchange

# If running manually
# Logs appear in terminal
```

### Verify Installation
```bash
# Check if files exist
ls -la /home/ubuntu/yz/Web3/网站test1/

# Check if dependencies installed
ls -la /home/ubuntu/yz/Web3/网站test1/node_modules/

# Test server response
curl http://localhost:3104
```

## 🎯 What's Working Right Now

- ✅ Web server running on port 3104
- ✅ All HTML/CSS/JS files created
- ✅ Responsive design implemented
- ✅ Scroll animations working
- ✅ VPN detection active
- ✅ MetaMask integration ready
- ✅ Dashboard navigation ready
- ⏳ SSL certificate (needs configuration)
- ⏳ Domain (needs DNS setup)

## 📚 Documentation

- `README.md` - Project overview
- `DEPLOYMENT.md` - Full deployment guide
- `FEATURES.md` - Detailed feature list
- `QUICKSTART.md` - This file

## 🔐 Security Notes

- VPN detection requires external network access
- MetaMask requires HTTPS in production
- Always use SSL certificates for production
- Keep your server and dependencies updated

---

**Ready to go live?** Follow Steps 1-4 above! 🚀
