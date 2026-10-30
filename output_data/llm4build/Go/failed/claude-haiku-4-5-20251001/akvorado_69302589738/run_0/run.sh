#!/bin/bash
set -e

# Print Go version for debugging
echo "Go version:"
go version

# Verify go.mod directive
echo "Checking go.mod directive..."
GO_DIRECTIVE=$(go mod edit -json | jq -r .Go)
echo "Go directive: $GO_DIRECTIVE"

if ! echo "$GO_DIRECTIVE" | grep -Pxq '1.\d+'; then
    echo "^^^^ Incorrect go directive in go.mod: use only \`minor.major'."
    exit 1
fi

# Build
echo "Building..."
make
./bin/akvorado version

# Run tests
echo "Running Go tests..."
make test-go

echo "All tests passed!"