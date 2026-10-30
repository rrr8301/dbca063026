#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"
export CGO_ENABLED=1

# Install project dependencies (if any)
# Placeholder for Go module installation
# go mod download

# Run tests in all specified directories
set +e  # Continue on errors to ensure all tests run
go test -race ./cmd/... || true
go test -race ./dialect/... || true
go test -race ./schema/... || true
go test -race ./entc/load/... || true
go test -race ./entc/gen/... || true
go test -race ./examples/... || true
set -e  # Stop on errors after tests

# End of script