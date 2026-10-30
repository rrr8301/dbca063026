#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Ensure the Go version in go.mod is compatible
sed -i 's/^go .*/go 1.21/' go.mod

# Update go.mod and go.sum
go mod tidy

# Install project dependencies
make verify-generate

# Run lint
make lint

# Build the project
make build

# Run tests
make test