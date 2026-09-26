#!/bin/bash

set -e

# Print environment for debugging
echo "=== Environment ==="
echo "Go version: $(go version)"
echo "Python version: $(python3 --version)"
echo "GOARCH: ${GOARCH}"
echo "CGO_ENABLED: ${CGO_ENABLED}"
echo "SKIP_PYTHON_BINDINGS_TESTS: ${SKIP_PYTHON_BINDINGS_TESTS}"
echo "===================="

# Change to workspace directory
cd /workspace

# Install project dependencies
echo "Installing project dependencies..."
make install.dependencies

# Run tests
echo "Running tests..."
make test \
    GOARCH=amd64 \
    CGO_ENABLED=1 \
    SKIP_PYTHON_BINDINGS_TESTS=0

echo "All tests completed successfully!"