#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
# Assuming dependencies are managed via go.mod and go.sum
go mod download

# Run tests
go test -v -race -coverprofile=coverage.out -covermode=atomic ./server/...

# Note: Coverage upload is skipped