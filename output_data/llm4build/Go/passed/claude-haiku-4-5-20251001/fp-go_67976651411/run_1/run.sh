#!/bin/bash

set -e

# Print Go version for debugging
echo "Go version:"
go version

# Navigate to workspace (in case we're not already there)
cd /workspace

# Tidy Go modules
echo "Running go mod tidy..."
go mod tidy

# Run tests with coverage
echo "Running tests with coverage..."
go test -race -coverprofile=coverage.txt -covermode=atomic -coverpkg=./... ./... || TEST_FAILED=1

# Print coverage summary
if [ -f coverage.txt ]; then
    echo "Coverage report generated: coverage.txt"
    echo "Coverage summary:"
    go tool cover -func=coverage.txt | tail -1
fi

# Exit with failure if tests failed
if [ "$TEST_FAILED" = "1" ]; then
    echo "Tests failed!"
    exit 1
fi

echo "All tests passed!"
exit 0