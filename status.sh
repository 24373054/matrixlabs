#!/bin/bash

# MatrixLab Exchange - Status Script
# Check application status

PROJECT_DIR="/home/ubuntu/yz/Web3/网站test1"
PID_FILE="$PROJECT_DIR/.app.pid"

echo "=========================================="
echo "MatrixLab Exchange - Status Check"
echo "=========================================="
echo ""

# Check PID file
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    echo "📄 PID File: $PID_FILE"
    echo "   PID: $PID"
    
    # Check if process is running
    if ps -p "$PID" > /dev/null 2>&1; then
        PROCESS_CMD=$(ps -p "$PID" -o args= 2>/dev/null)
        echo "   Status: ✅ Running"
        echo "   Command: $PROCESS_CMD"
        
        # Get process info
        CPU_MEM=$(ps -p "$PID" -o %cpu,%mem,etime --no-headers)
        echo "   Resources: $CPU_MEM"
    else
        echo "   Status: ❌ Not Running (stale PID file)"
    fi
else
    echo "📄 PID File: Not found"
fi

echo ""

# Check port 3104
echo "🔌 Port 3104:"
PORT_PID=$(lsof -ti:3104 2>/dev/null)
if [ -n "$PORT_PID" ]; then
    PORT_CMD=$(ps -p "$PORT_PID" -o args= 2>/dev/null)
    echo "   Status: ✅ In Use"
    echo "   PID: $PORT_PID"
    echo "   Process: $PORT_CMD"
else
    echo "   Status: ⚪ Available"
fi

echo ""

# Check local connection
echo "🌐 Local Connection (http://localhost:3104):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3104 --connect-timeout 2 > /dev/null 2>&1; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3104 --connect-timeout 2)
    echo "   Status: ✅ Responding"
    echo "   HTTP Code: $HTTP_CODE"
else
    echo "   Status: ❌ Not Responding"
fi

echo ""

# Check HTTPS
echo "🔒 HTTPS (https://exchange.matrixlab.work):"
if curl -s -o /dev/null -w "%{http_code}" https://exchange.matrixlab.work --connect-timeout 5 > /dev/null 2>&1; then
    HTTPS_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://exchange.matrixlab.work --connect-timeout 5)
    echo "   Status: ✅ Responding"
    echo "   HTTP Code: $HTTPS_CODE"
else
    echo "   Status: ❌ Not Responding"
fi

echo ""

# Check Nginx
echo "🔧 Nginx:"
if systemctl is-active --quiet nginx; then
    echo "   Status: ✅ Running"
else
    echo "   Status: ❌ Not Running"
fi

echo ""

# Recent logs
if [ -f "$PROJECT_DIR/app.log" ]; then
    echo "📋 Recent Logs (last 5 lines):"
    echo "----------------------------------------"
    tail -5 "$PROJECT_DIR/app.log"
    echo "----------------------------------------"
    echo "   Full logs: tail -f $PROJECT_DIR/app.log"
else
    echo "📋 Logs: No log file found"
fi

echo ""
echo "=========================================="
echo "Management Commands:"
echo "   Start:   ./start.sh"
echo "   Stop:    ./stop.sh"
echo "   Restart: ./restart.sh"
echo "   Status:  ./status.sh"
echo "=========================================="
