#!/bin/bash
set -e

# Set GOPATH
export GOPATH=/workspace
export PATH=$GOPATH/bin:$PATH

# Enable CGO for race detector
export CGO_ENABLED=1

# Change to working directory
cd $GOPATH/src/github.com/go-chi/chi

# Fetch dependencies
echo "Fetching dependencies..."
go mod download

# Run tests
echo "Running tests..."
make test

echo "All tests completed successfully!"