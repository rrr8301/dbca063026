#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install Go dependencies
echo "Installing Go dependencies..."
go mod download
go mod verify

# Install Node.js dependencies
echo "Installing Node.js dependencies..."
cd webrtc
yarn install --frozen-lockfile
cd ..

# Run Go tests
echo "Running Go tests..."
go test -v ./...

# Run Go linting
echo "Running golangci-lint..."
golangci-lint run ./...

# Run ESLint
echo "Running ESLint..."
cd webrtc
yarn run lint
cd ..

echo "All tests completed successfully!"