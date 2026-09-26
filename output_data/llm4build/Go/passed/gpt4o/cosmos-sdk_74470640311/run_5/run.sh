#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Ensure the Go version in go.mod is compatible
sed -i 's/^go 1\.25\.9/go 1.20/' go.mod

# Install Go dependencies
go mod download

# Run integration tests
make test-integration-cov || { echo "Makefile error: Check line 54 for syntax issues."; exit 1; }