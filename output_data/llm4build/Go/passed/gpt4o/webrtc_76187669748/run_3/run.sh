#!/bin/bash

# Ensure the script is executable
chmod +x run.sh

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Navigate to the project directory
cd /workspace/webrtc

# Install project dependencies
go mod tidy

# Run tests
go test ./...