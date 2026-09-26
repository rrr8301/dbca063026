#!/bin/bash
set -e

# Read Go version from go.version file
GO_VERSION=$(cat go.version)
echo "Installing Go version: $GO_VERSION"

# Install Go
curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o /tmp/go.tar.gz
tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Verify installations
echo "Go version:"
go version
echo "Node.js version:"
node --version
echo "Deno version:"
deno --version

# Run Go tests
echo "Running Go tests..."
go test -race ./internal/...

echo "All tests completed successfully!"