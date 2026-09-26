#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Ensure Go is in PATH
export PATH="/usr/local/go/bin:${PATH}"
export GOPATH="/home/testuser/go"
export GOROOT="/usr/local/go"

# Run tests with gotestsum
go run gotest.tools/gotestsum@latest -f testname -- ./... -race -count=1 -coverprofile=coverage.txt -covermode=atomic -shuffle=on

echo "Tests completed successfully"