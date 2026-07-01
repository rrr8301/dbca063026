#!/bin/bash

# Setup Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Check if go.mod is valid
if ! go mod tidy; then
    echo "Error: go.mod contains invalid syntax or unsupported directives."
    exit 1
fi

# Run go list
go list -json > go.list

# Update apt-get
apt-get update

# Install Node.js dependencies
npm install

# Run golangci-lint
$(go env GOPATH)/bin/golangci-lint run --timeout 10m0s || echo "golangci-lint encountered issues."

# Build Kratos
if ! make install; then
    echo "Error: Failed to build Kratos."
    exit 1
fi

# Run Go tests
if ! make test-coverage; then
    echo "Error: Go tests failed."
    exit 1
fi