#!/bin/bash

# MatrixLab Exchange - Start Script
# Safe start script that won't affect other processes

PROJECT_DIR="/home/ubuntu/yz/Web3/网站test1"
PID_FILE="$PROJECT_DIR/.app.pid"
LOG_FILE="$PROJECT_DIR/app.log"

cd "$PROJECT_DIR" || exit 1

# Check if already running
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "❌ Application is already running (PID: $PID)"
        echo "   Use ./stop.sh to stop it first"
        exit 1
    else
        # PID file exists but process is dead, clean it up
        rm -f "$PID_FILE"
    fi
fi

# Check if port 3104 is in use
if lsof -Pi :3104 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "❌ Port 3104 is already in use by another process"
    echo "   Please check: sudo lsof -i :3104"
    exit 1
fi

# Start the application
echo "🚀 Starting MatrixLab Exchange..."
echo "   Project: $PROJECT_DIR"
echo "   Port: 3104"
echo "   Log: $LOG_FILE"
echo ""

# Start in background and save PID
nohup npm start > "$LOG_FILE" 2>&1 &
APP_PID=$!

# Save PID to file
echo "$APP_PID" > "$PID_FILE"

# Wait a moment and check if it started successfully
sleep 2

if ps -p "$APP_PID" > /dev/null 2>&1; then
    echo "✅ Application started successfully!"
    echo "   PID: $APP_PID"
    echo "   Local: http://localhost:3104"
    echo "   Public: https://exchange.matrixlab.work"
    echo ""
    echo "📋 Management:"
    echo "   Stop: ./stop.sh"
    echo "   Logs: tail -f $LOG_FILE"
    echo "   Status: ./status.sh"
else
    echo "❌ Failed to start application"
    echo "   Check logs: cat $LOG_FILE"
    rm -f "$PID_FILE"
    exit 1
fi
