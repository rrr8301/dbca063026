#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Navigate to the workspace directory
cd /workspace

# Ensure Go modules are enabled
export GO111MODULE=on

# Correct the Go version in go.mod
sed -i 's/^go .*/go 1.26/' go.mod

# Run tests
go test ./...