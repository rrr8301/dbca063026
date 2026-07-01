#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install Go dependencies
echo "Installing Go dependencies..."
go mod download
go mod verify

# Install Node.js dependencies if webrtc directory exists
if [ -d "webrtc" ]; then
    echo "Installing Node.js dependencies..."
    cd webrtc
    yarn install --frozen-lockfile
    cd ..
else
    echo "Skipping Node.js dependencies (webrtc directory not found)"
fi

# Run Go tests
echo "Running Go tests..."
go test -v ./...

# Run Go linting
echo "Running golangci-lint..."
golangci-lint run ./...

# Run ESLint if webrtc directory exists
if [ -d "webrtc" ]; then
    echo "Running ESLint..."
    cd webrtc
    yarn run lint
    cd ..
else
    echo "Skipping ESLint (webrtc directory not found)"
fi

echo "All tests completed successfully!"