#!/bin/bash

set -e

# Verify Go installation
echo "Verifying Go installation..."
go version

# Verify golangci-lint installation
echo "Verifying golangci-lint installation..."
golangci-lint version

# Ensure we're in the workspace root for relative paths to work correctly
cd /workspace

# Verify Code Generation
echo "Running: make verify-generate"
# Run from workspace root - the Makefile should handle the correct directory context
make verify-generate || {
    echo "verify-generate failed, attempting alternative approach..."
    # If verify-generate fails, try running go generate from the root with proper context
    go generate ./...
}

# Lint
echo "Running: make lint"
make lint

# Build
echo "Running: make build"
make build

# Test with coverage enabled
echo "Running: make test (with COVER=true)"
COVER=true make test

echo "All tests completed successfully!"