#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Navigate to the workspace directory
cd /workspace

# Ensure Go modules are enabled
export GO111MODULE=on

# Run tests
go test ./...