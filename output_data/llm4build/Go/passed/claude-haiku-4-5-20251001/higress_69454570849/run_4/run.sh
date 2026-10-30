#!/bin/bash

set -e

# Print Go version for verification
echo "=== Go Version ==="
go version

# Restore any patches
echo "=== Restoring patches ==="
git stash || true

# Install project dependencies
echo "=== Installing project dependencies ==="
go mod download

# Run coverage tests
echo "=== Running coverage tests ==="
GOPROXY="https://proxy.golang.org,direct" make go.test.coverage

# Print test completion message
echo "=== Coverage tests completed ==="
if [ -f ./coverage.xml ]; then
    echo "Coverage report generated: ./coverage.xml"
    ls -lh ./coverage.xml
elif [ -f ./coverage.out ]; then
    echo "Coverage report generated: ./coverage.out"
    ls -lh ./coverage.out
else
    echo "Error: coverage report not found"
    exit 1
fi

echo "=== All tests completed ==="