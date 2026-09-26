#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Navigate to the workspace
cd /workspace

# Install project dependencies
# Assuming dependencies are managed via go.mod and go.sum
if ! go mod download; then
    echo "Failed to download Go modules"
    exit 1
fi

# Run tests
if ! go test -v -race -coverprofile=coverage.out -covermode=atomic ./server/...; then
    echo "Tests failed"
    exit 1
fi

# Note: Coverage upload is skipped