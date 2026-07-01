#!/bin/bash
set -e

# Set environment variables
export CGO_ENABLED=1
export PATH="/usr/local/go/bin:$PATH"

# Navigate to workspace
cd /workspace

# Extract Go version from go.mod
GO_VERSION=$(grep -m1 "^go " go.mod | awk '{print $2}')
echo "Go version from go.mod: $GO_VERSION"

# Install the correct Go version if needed
INSTALLED_GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
if [ "$INSTALLED_GO_VERSION" != "$GO_VERSION" ]; then
    echo "Installing Go $GO_VERSION..."
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o go.tar.gz
    tar -C /usr/local -xzf go.tar.gz
    rm go.tar.gz
fi

# Verify Go installation
go version

# Verify Node.js installation
node --version
npm --version

# Install UI dependencies
echo "Installing UI dependencies..."
cd /workspace/app/ui/app
npm ci
cd /workspace

# Install tscriptify
echo "Installing tscriptify..."
go install github.com/tkrajina/typescriptify-golang-structs/tscriptify@latest

# Run go generate
echo "Running go generate..."
go generate ./...

# Run go tests
echo "Running go tests..."
go test -count=1 -benchtime=1x ./...

echo "All tests completed successfully!"