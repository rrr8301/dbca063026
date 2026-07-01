#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
cd /workspace/webrtc
go mod download

# Run tests
go test ./...