#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
go mod tidy
go mod download

# Run tests
set -e  # Stop on errors
go test ./...  # Run all tests