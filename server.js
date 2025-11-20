const express = require('express');
const path = require('path');
const https = require('https');
const http = require('http');
const app = express();

// Serve static files
app.use(express.static('public'));

// API proxy for IP detection (avoid CORS issues)
app.get('/api/check-ip', async (req, res) => {
  // Get client's real IP
  const clientIP = req.headers['x-forwarded-for'] || 
                   req.headers['x-real-ip'] || 
                   req.connection.remoteAddress;
  
  // Helper function to try a service
  const tryService = (url) => {
    return new Promise((resolve, reject) => {
      const protocol = url.startsWith('https') ? https : http;
      
      protocol.get(url, (apiRes) => {
        let data = '';
        
        apiRes.on('data', (chunk) => {
          data += chunk;
        });
        
        apiRes.on('end', () => {
          try {
            const ipData = JSON.parse(data);
            // Check if response has error (rate limited, etc)
            if (ipData.error || ipData.status === 'fail') {
              reject(new Error(ipData.message || 'API error'));
            } else {
              resolve(ipData);
            }
          } catch (e) {
            reject(e);
          }
        });
      }).on('error', (e) => {
        reject(e);
      });
    });
  };
  
  // Try multiple services in order (using HTTP to avoid SSL issues)
  const services = [
    'http://ip-api.com/json/',
    'http://ipinfo.io/json',
    'https://api.ipify.org?format=json',
    'http://ifconfig.me/all.json'
  ];
  
  for (const service of services) {
    try {
      const ipData = await tryService(service);
      
      // Success! Return the data
      return res.json({
        success: true,
        data: ipData,
        clientIP: clientIP,
        source: service
      });
    } catch (e) {
      console.log(`Service ${service} failed:`, e.message);
      // Continue to next service
    }
  }
  
  // All services failed, return fallback
  res.json({
    success: false,
    error: 'All IP services failed',
    clientIP: clientIP,
    fallback: true
  });
});

// Main route
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

const PORT = process.env.PORT || 3104;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`MatrixLab Exchange Platform running on port ${PORT}`);
  console.log(`Access at: http://localhost:${PORT}`);
});
