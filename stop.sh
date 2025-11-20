#!/bin/bash

# MatrixLab Exchange - Stop Script
# Safe stop script that only stops this specific application

PROJECT_DIR="/home/ubuntu/yz/Web3/网站test1"
PID_FILE="$PROJECT_DIR/.app.pid"

cd "$PROJECT_DIR" || exit 1

# Check if PID file exists
if [ ! -f "$PID_FILE" ]; then
    echo "⚠️  No PID file found"
    echo "   Application may not be running or was started manually"
    echo ""
    echo "   Searching for process..."
    
    # Try to find the process by checking port 3104
    PORT_PID=$(lsof -ti:3104 2>/dev/null)
    if [ -n "$PORT_PID" ]; then
        # Verify it's our node process
        if ps -p "$PORT_PID" -o args= | grep -q "node.*server.js"; then
            echo "   Found process on port 3104 (PID: $PORT_PID)"
            read -p "   Kill this process? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                kill "$PORT_PID"
                sleep 1
                if ps -p "$PORT_PID" > /dev/null 2>&1; then
                    echo "   Process still running, forcing..."
                    kill -9 "$PORT_PID"
                fi
                echo "✅ Process stopped"
            else
                echo "   Cancelled"
            fi
        else
            echo "   Process on port 3104 is not our application"
        fi
    else
        echo "   No process found on port 3104"
    fi
    exit 0
fi

# Read PID from file
PID=$(cat "$PID_FILE")

# Check if process is actually running
if ! ps -p "$PID" > /dev/null 2>&1; then
    echo "⚠️  Process not running (PID: $PID)"
    echo "   Cleaning up PID file..."
    rm -f "$PID_FILE"
    exit 0
fi

# Verify it's our process (check if it's npm or node process)
PROCESS_CMD=$(ps -p "$PID" -o args= 2>/dev/null)
if ! echo "$PROCESS_CMD" | grep -qE "(npm start|node.*server\.js)"; then
    echo "❌ PID $PID is not our application process"
    echo "   Process: $PROCESS_CMD"
    echo "   Cleaning up PID file..."
    rm -f "$PID_FILE"
    exit 1
fi

echo "🛑 Stopping MatrixLab Exchange..."
echo "   PID: $PID"
echo "   Process: $PROCESS_CMD"
echo ""

# Get all child processes (including node process)
CHILD_PIDS=$(pgrep -P "$PID" 2>/dev/null)

# Try graceful shutdown first - kill parent and children
kill "$PID" 2>/dev/null
if [ -n "$CHILD_PIDS" ]; then
    for CHILD_PID in $CHILD_PIDS; do
        kill "$CHILD_PID" 2>/dev/null
    done
fi

# Wait up to 3 seconds for graceful shutdown
for i in {1..3}; do
    if ! ps -p "$PID" > /dev/null 2>&1; then
        # Also check if children are stopped
        ALL_STOPPED=true
        if [ -n "$CHILD_PIDS" ]; then
            for CHILD_PID in $CHILD_PIDS; do
                if ps -p "$CHILD_PID" > /dev/null 2>&1; then
                    ALL_STOPPED=false
                    break
                fi
            done
        fi
        
        if [ "$ALL_STOPPED" = true ]; then
            # Double check port is free
            sleep 1
            if ! lsof -Pi :3104 -sTCP:LISTEN -t >/dev/null 2>&1; then
                echo "✅ Application stopped successfully"
                rm -f "$PID_FILE"
                exit 0
            fi
        fi
    fi
    sleep 1
done

# If still running, force kill
echo "⚠️  Graceful shutdown timeout, forcing..."
kill -9 "$PID" 2>/dev/null
if [ -n "$CHILD_PIDS" ]; then
    for CHILD_PID in $CHILD_PIDS; do
        kill -9 "$CHILD_PID" 2>/dev/null
    done
fi

# Also kill any process on port 3104 (cleanup)
PORT_PIDS=$(lsof -ti:3104 2>/dev/null)
if [ -n "$PORT_PIDS" ]; then
    echo "   Cleaning up processes on port 3104..."
    for PORT_PID in $PORT_PIDS; do
        kill -9 "$PORT_PID" 2>/dev/null
    done
fi

sleep 1

# Verify port is free
if lsof -Pi :3104 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "❌ Warning: Port 3104 may still be in use"
else
    echo "✅ Application stopped and port cleared"
fi

# Clean up PID file
rm -f "$PID_FILE"
