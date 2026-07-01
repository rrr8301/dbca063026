#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Enable CGO for race detection
export CGO_ENABLED=1

# Install project dependencies
# Assuming dependencies are managed via go.mod
go mod download

# Run tests with coverage
go test -race --coverprofile=coverage.coverprofile --covermode=atomic ./...