#!/bin/bash

# Setup Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Run go list
go list -json > go.list

# Update apt-get
apt-get update

# Install Node.js dependencies
npm install

# Run golangci-lint
$(go env GOPATH)/bin/golangci-lint run --timeout 10m0s

# Build Kratos
make install

# Run Go tests
make test-coverage