#!/bin/bash
set -e

# Extract Go version from go.mod
GO_VERSION=$(grep "^go " go.mod | awk '{print $2}')
echo "Go version from go.mod: $GO_VERSION"

# Download and install the specific Go version if needed
# For simplicity, we assume the base image Go version is compatible
# If strict version matching is needed, uncomment below:
# CURRENT_GO=$(go version | awk '{print $3}' | sed 's/go//')
# if [ "$CURRENT_GO" != "$GO_VERSION" ]; then
#   echo "Installing Go $GO_VERSION..."
#   curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o go.tar.gz
#   tar -C /usr/local -xzf go.tar.gz
#   rm go.tar.gz
# fi

# Verify Go installation
go version

# Get dependencies
echo "Getting dependencies..."
go get -v -t -d ./...

# Lint: go vet
echo "Running go vet..."
go vet -stdmethods=false $(go list ./...)

# Check go mod tidy
echo "Checking go mod tidy..."
go mod tidy
if ! test -z "$(git status --porcelain)"; then
  echo "Please run 'go mod tidy'"
  exit 1
fi

# Run tests with race detector and coverage
echo "Running tests..."
go test -race -coverprofile=coverage.txt -covermode=atomic ./...

echo "All tests passed!"