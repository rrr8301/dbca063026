#!/bin/bash

set -e

# Display Go version
echo "Go version:"
go version

# Install dependencies
echo "Installing Go dependencies..."
go mod download

# Run tests with verbose output and race detector
echo "Running tests..."
go test -v -race ./...

exit 0