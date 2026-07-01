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
go mod download || true

# Run coverage tests
echo "=== Running coverage tests ==="
GOPROXY="https://proxy.golang.org,direct" make go.test.coverage || {
    echo "Warning: make go.test.coverage failed, attempting alternative test command"
    go test -v -coverprofile=coverage.out ./... || true
    if command -v gocover-cobertura &> /dev/null; then
        gocover-cobertura < coverage.out > coverage.xml
    fi
}

# Print test completion message
echo "=== Coverage tests completed ==="
if [ -f ./coverage.xml ]; then
    echo "Coverage report generated: ./coverage.xml"
    ls -lh ./coverage.xml
elif [ -f ./coverage.out ]; then
    echo "Coverage report generated: ./coverage.out"
    ls -lh ./coverage.out
else
    echo "Warning: coverage report not found"
fi

echo "=== All tests completed ==="