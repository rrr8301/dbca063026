#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Lint with golangci-lint
echo "Running linting..."
export GOFLAGS="-buildvcs=false -tags=next"
/app/bin/golangci-lint run -v ./...

# Build and run tests
echo "Running build and tests..."
make test

echo "All checks passed!"