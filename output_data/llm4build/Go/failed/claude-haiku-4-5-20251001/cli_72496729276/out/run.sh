#!/bin/bash
set -e

# Navigate to the workspace directory where go.mod is located
cd /workspace

# Download Go dependencies
echo "Downloading Go dependencies..."
go mod download

# Run unit and integration tests with race detector
echo "Running unit and integration tests..."
go test -race -tags=integration ./...

echo "All tests completed successfully!"