#!/bin/bash
set -e

# Print environment info
echo "=== Environment ==="
go version
echo "CGO_ENABLED=${CGO_ENABLED}"
echo "GOPATH=${GOPATH}"
echo "PATH=${PATH}"
echo ""

# Navigate to workspace
cd /workspace

# Ensure Go modules are available
echo "=== Downloading Go dependencies ==="
go mod download
go mod verify

# Run tests with gotestsum and coverage
echo "=== Running Tests ==="
go run gotest.tools/gotestsum@latest --junitfile unit-tests.xml --format pkgname -- -v -cover -coverpkg=./... -coverprofile=coverage.txt -covermode=atomic -timeout 20m ./...

# Print test summary
echo ""
echo "=== Test Execution Complete ==="
echo "JUnit XML report: unit-tests.xml"
echo "Coverage report: coverage.txt"

# Exit with success
exit 0