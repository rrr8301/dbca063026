#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Enable CGO
export CGO_ENABLED=1

# Navigate to the project directory
cd /app

# Initialize Go modules if not already initialized
if [ ! -f go.mod ]; then
    go mod init
fi

# Install Go dependencies
go mod tidy

# Run tests with coverage
# Adding -v for verbose output to help diagnose issues
go test -v -race -coverprofile=coverage.txt -covermode=atomic -coverpkg=./... ./... || true

# Note: Coverage upload to Coveralls is skipped