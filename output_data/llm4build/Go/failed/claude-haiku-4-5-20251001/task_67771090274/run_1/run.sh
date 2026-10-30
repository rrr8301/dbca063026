#!/bin/bash

set -e

# Print Go version for verification
echo "Go version:"
go version

# Download Go modules
echo "Downloading Go modules..."
go mod download

# Pre-install gotestsum to ensure it's in PATH
echo "Installing gotestsum..."
go install gotest.tools/gotestsum@latest

# Build the project
echo "Building task..."
go build -o ./bin/task -v ./cmd/task

# Run tests
echo "Running tests..."
./bin/task test --output=group --output-group-begin='::group::{{.TASK}}' --output-group-end='::endgroup::' || TEST_FAILED=1

# Exit with appropriate code
if [ "$TEST_FAILED" = "1" ]; then
    echo "Tests completed with failures"
    exit 1
fi

echo "All tests passed successfully"
exit 0