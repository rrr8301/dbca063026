#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Start nix daemon if not already running
if [ -S /nix/var/nix/daemon-socket/socket ]; then
    echo "Nix daemon socket already exists"
else
    echo "Starting nix daemon..."
    nix-daemon &
    sleep 2
fi

# Run lints and tests using just
just lint test