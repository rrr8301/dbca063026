#!/bin/bash
set -e

# Print Go version for debugging
go version

# Print golangci-lint version for debugging
golangci-lint version

# Build all
echo "=== Building all ==="
make all

# Vet
echo "=== Running go vet ==="
make vet

# golangci-lint
echo "=== Running golangci-lint ==="
golangci-lint run

# Test
echo "=== Running tests ==="
make test

# End-to-end tests
echo "=== Running end-to-end tests ==="
make e2evv

# Build test mobile
echo "=== Building and testing mobile ==="
make build-test-mobile

echo "=== All tests completed ==="