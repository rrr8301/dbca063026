#!/bin/bash

set -e

# Extract Go version from go.mod
GO_VERSION=$(grep "^go " go.mod | cut -d' ' -f2 | cut -d. -f1,2)
echo "Go version from go.mod: ${GO_VERSION}"

# Verify Go installation
go version

# Verify golangci-lint installation
golangci-lint version

# Verify Code Generation
echo "Running: make verify-generate"
make verify-generate

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