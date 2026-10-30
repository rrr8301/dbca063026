#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"
export GOTOOLCHAIN=local

# Enable CGO
export CGO_ENABLED=1

# Ensure the Go version matches the installed version
go version

# Install project dependencies
go mod download

# Run tests
go test -race -v ./...