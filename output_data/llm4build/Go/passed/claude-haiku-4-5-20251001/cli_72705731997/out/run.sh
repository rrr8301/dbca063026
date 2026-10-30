#!/bin/bash
set -e

# Print Go version for debugging
echo "Go version:"
go version

# Download dependencies
echo "Downloading Go dependencies..."
go mod download

# Run unit and integration tests
echo "Running unit and integration tests..."
go test -race -tags=integration ./...

# Build the project
echo "Building project..."
go build -v ./cmd/gh

echo "Build and tests completed successfully!"