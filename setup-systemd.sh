#!/bin/bash

# MatrixLab Exchange - Systemd Service Setup
# This ensures the app runs automatically on server restart

echo "==================================="
echo "MatrixLab Exchange Systemd Setup"
echo "==================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Get the current directory
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER=$(stat -c '%U' "$APP_DIR")

echo "App Directory: $APP_DIR"
echo "Running as user: $USER"
echo ""

# Create systemd service file
SERVICE_FILE="/etc/systemd/system/matrixlab-exchange.service"

echo "Creating systemd service..."
cat > $SERVICE_FILE << EOF
[Unit]
Description=MatrixLab Exchange Web3 Platform
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$APP_DIR
ExecStart=/usr/bin/node $APP_DIR/server.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=PORT=3104

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=matrixlab-exchange

[Install]
WantedBy=multi-user.target
EOF

echo "Service file created at: $SERVICE_FILE"
echo ""

# Reload systemd
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Enable service
echo "Enabling service..."
systemctl enable matrixlab-exchange.service

# Start service
echo "Starting service..."
systemctl start matrixlab-exchange.service

# Check status
echo ""
echo "Service status:"
systemctl status matrixlab-exchange.service --no-pager

echo ""
echo "==================================="
echo "Service Management Commands:"
echo "==================================="
echo ""
echo "Start:   sudo systemctl start matrixlab-exchange"
echo "Stop:    sudo systemctl stop matrixlab-exchange"
echo "Restart: sudo systemctl restart matrixlab-exchange"
echo "Status:  sudo systemctl status matrixlab-exchange"
echo "Logs:    sudo journalctl -u matrixlab-exchange -f"
echo ""
echo "==================================="
