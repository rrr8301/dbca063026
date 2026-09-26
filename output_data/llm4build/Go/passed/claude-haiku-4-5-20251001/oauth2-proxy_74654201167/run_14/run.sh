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
# Set GOFLAGS to ensure proper module handling during code generation
# Set GOWORK=off to avoid workspace mode issues
export GOFLAGS="-mod=mod"
export GOWORK=off
# Run go generate from workspace root to ensure relative paths resolve correctly
go generate ./...

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