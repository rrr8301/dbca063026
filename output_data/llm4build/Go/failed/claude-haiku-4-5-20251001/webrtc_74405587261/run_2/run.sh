#!/bin/bash
set -e

# Navigate to webrtc directory (assuming the repo root contains webrtc/)
cd /workspace/webrtc || cd /workspace

# Download Go dependencies
echo "Downloading Go dependencies..."
go mod download
go mod verify

# Install Node.js dependencies
echo "Installing Node.js dependencies..."
yarn install --frozen-lockfile

# Run Go tests
echo "Running Go tests..."
go test -v -race -coverprofile=coverage.out ./...

# Run Go vet
echo "Running Go vet..."
go vet ./...

# Run golangci-lint
echo "Running golangci-lint..."
golangci-lint run

# Run JavaScript/TypeScript linting (if eslint is configured)
if [ -f ".eslintrc.json" ]; then
    echo "Running ESLint..."
    yarn lint
fi

# Run JavaScript/TypeScript tests (if test script exists in package.json)
if grep -q '"test"' package.json; then
    echo "Running JavaScript tests..."
    yarn test
fi

echo "All tests completed!"