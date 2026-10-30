#!/bin/bash
set -e

# Print Go version for debugging
go version

# Install go-test-json-to-loki
echo "Installing go-test-json-to-loki..."
go install calmh.dev/go-test-json-to-loki@latest

# Build
echo "Building..."
go run build.go

# Test with JSON output piped to go-test-json-to-loki
echo "Running tests..."
GOFLAGS="-json" CGO_ENABLED="1" go run build.go test | go-test-json-to-loki || true

echo "Build and test completed."