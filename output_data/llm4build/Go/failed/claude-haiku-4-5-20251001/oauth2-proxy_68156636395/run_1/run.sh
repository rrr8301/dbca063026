#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Verify Go installation
echo "Go version:"
go version

# Verify golangci-lint installation
echo "golangci-lint version:"
golangci-lint --version

# Run verify-generate
echo "Running: make verify-generate"
make verify-generate

# Run lint
echo "Running: make lint"
make lint

# Run build (not skipped in local build context)
echo "Running: make build"
make build

# Run test with coverage enabled
echo "Running: make test (with COVER=true)"
COVER=true make test

echo "All tests completed successfully!"