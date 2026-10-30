#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
cd webrtc
go mod tidy

# Run tests
go test ./...