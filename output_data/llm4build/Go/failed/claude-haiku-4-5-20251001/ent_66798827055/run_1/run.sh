#!/bin/bash

set -e

# Print Go version for verification
echo "Go version:"
go version

# Navigate to cmd directory where tests are located
cd /workspace/cmd

# Run tests with race detector
# The -race flag detects data races
# The ./... pattern runs all tests in the current package and subdirectories
echo "Running Go tests in cmd directory..."
go test -race ./...

echo "All tests completed successfully!"