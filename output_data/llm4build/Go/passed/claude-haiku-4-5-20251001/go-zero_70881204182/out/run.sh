#!/bin/bash

set -e

# Print Go version for debugging
echo "Go version:"
go version

# Extract Go version from go.mod if it exists
if [ -f "go.mod" ]; then
    echo "Go module file found. Extracting version..."
    GO_MOD_VERSION=$(grep "^go " go.mod | awk '{print $2}')
    echo "Go version from go.mod: $GO_MOD_VERSION"
fi

# Get dependencies
echo "Getting dependencies..."
go get -v -t -d ./...

# Run linting
echo "Running linting..."
go vet -stdmethods=false $(go list ./...)

# Check if go.mod needs tidying
echo "Checking go.mod tidiness..."
go mod tidy
if ! test -z "$(git status --porcelain)"; then
    echo "ERROR: Please run 'go mod tidy'"
    exit 1
fi

# Run tests with race detector and coverage
echo "Running tests with race detector and coverage..."
go test -race -coverprofile=coverage.txt -covermode=atomic ./... || TEST_FAILED=1

# Print coverage summary
if [ -f "coverage.txt" ]; then
    echo "Coverage file generated: coverage.txt"
    echo "Coverage summary:"
    go tool cover -func=coverage.txt | tail -1
fi

# Exit with failure if tests failed
if [ "$TEST_FAILED" = "1" ]; then
    echo "Tests failed!"
    exit 1
fi

echo "All checks passed!"
exit 0