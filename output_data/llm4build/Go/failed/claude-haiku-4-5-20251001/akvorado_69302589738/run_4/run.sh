#!/bin/bash
set -e

# Print Go version for debugging
echo "Go version:"
go version

# Verify go.mod directive
echo "Checking go.mod directive..."
GO_DIRECTIVE=$(go mod edit -json | jq -r .Go)
echo "Go directive: $GO_DIRECTIVE"

if ! echo "$GO_DIRECTIVE" | grep -Pxq '1\.\d+'; then
    echo "^^^^ Incorrect go directive in go.mod: use only \`minor.major'."
    exit 1
fi

# Clean and reinstall node modules to fix native binding issues
echo "Cleaning and reinstalling node modules..."
rm -rf console/frontend/node_modules console/frontend/package-lock.json
cd console/frontend
pnpm install --force
cd /workspace

# Build
echo "Building..."
make

echo "Running akvorado version..."
./bin/akvorado version

# Run tests
echo "Running Go tests..."
make test-go

echo "All tests passed!"