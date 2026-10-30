#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Start nix daemon in the background
echo "Starting nix daemon..."
nix-daemon &
DAEMON_PID=$!

# Give the daemon time to start
sleep 2

# Run lints and tests using just
just lint test

# Clean up daemon
kill "${DAEMON_PID}" 2>/dev/null || true