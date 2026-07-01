#!/bin/bash

# Set Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Ensure the correct Go version is set in go.mod
go mod edit -go=1.26

# Install project dependencies
go mod download

# Run tests
make test