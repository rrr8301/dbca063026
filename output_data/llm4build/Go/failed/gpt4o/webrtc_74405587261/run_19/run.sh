#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Navigate to the project directory
cd /workspace/webrtc

# Install project dependencies
go mod download

# Run tests
go test ./...