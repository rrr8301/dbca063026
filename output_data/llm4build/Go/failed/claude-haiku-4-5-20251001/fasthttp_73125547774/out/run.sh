#!/bin/bash
set -e

# Print Go version for verification
go version

# Run tests with shuffle enabled
echo "Running tests with shuffle..."
go test -shuffle=on ./...

# Run tests with race detector and shuffle enabled
echo "Running tests with race detector..."
go test -race -shuffle=on ./...

echo "All tests passed!"