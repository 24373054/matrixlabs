#!/bin/bash

# MatrixLab Exchange - Restart Script
# Safely restart the application

echo "🔄 Restarting MatrixLab Exchange..."
echo ""

# Stop the application
./stop.sh

# Wait for port to be fully released
echo ""
echo "⏳ Waiting for port to be released..."
sleep 3

# Verify port is free
for i in {1..5}; do
    if ! lsof -Pi :3104 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "✅ Port 3104 is free"
        break
    fi
    echo "   Still waiting... ($i/5)"
    sleep 1
done

echo ""

# Start the application
./start.sh
