#!/bin/bash

set -e

# Print Go version for verification
echo "Go version:"
go version

# Download Go module dependencies
echo "Downloading Go dependencies..."
go mod download

# Run gofmt check
echo "Running gofmt check..."
if ! test -z $(gofmt -l .); then
    echo "gofmt check failed: code is not formatted"
    gofmt -d .
    exit 1
fi

# Run Go tests with 30m timeout, short flag, and verbose output
# The -short flag skips long-running tests (including integration tests requiring credentials)
echo "Running Go tests..."
go test -timeout 30m -short -v ./... || TEST_FAILED=1

# Exit with failure code if tests failed
if [ "${TEST_FAILED}" = "1" ]; then
    echo "Tests failed"
    exit 1
fi

echo "All tests passed!"
exit 0