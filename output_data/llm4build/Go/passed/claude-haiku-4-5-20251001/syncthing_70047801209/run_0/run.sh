#!/bin/bash

set -e

# Print Go version for verification
echo "Go version:"
go version

# Navigate to workspace
cd /workspace

# Build the project
echo "Building project..."
go build ./...

# Run tests
echo "Running tests..."
go test ./...

echo "Build and test completed successfully!"