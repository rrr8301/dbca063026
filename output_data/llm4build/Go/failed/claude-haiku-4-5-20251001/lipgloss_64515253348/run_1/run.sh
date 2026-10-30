#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Verify Go installation
echo "Go version:"
go version

# Run Go build
echo "Running Go build..."
go build ./...

# Run Go tests
echo "Running Go tests..."
go test -v ./...

echo "Build completed successfully"