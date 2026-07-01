#!/bin/bash

set -e

# Print Go version for verification
echo "Go version:"
go version

# Navigate to workspace
cd /workspace

# Download Go module dependencies
echo "Downloading Go dependencies..."
go mod download

# Run tests with verbose output and race detector
echo "Running tests..."
go test -v -race ./...

echo "All tests completed successfully!"