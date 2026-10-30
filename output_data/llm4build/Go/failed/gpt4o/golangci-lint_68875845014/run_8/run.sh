#!/bin/bash

# Set Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Ensure the correct Go version is set in go.mod
go mod edit -go=1.21

# Tidy up the go.mod file to ensure it's correct
go mod tidy

# Check for any syntax errors in go.mod
if ! go mod verify; then
    echo "Error: go.mod file has syntax errors."
    exit 1
fi

# Install project dependencies
go mod download

# Run tests
make test