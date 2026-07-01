#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
go mod tidy
go mod download

# Run tests
set +e  # Continue on errors
go test ./... || true  # Run all tests, continue even if some fail
set -e  # Stop on errors