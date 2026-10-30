#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Check and update go.mod to a compatible version
sed -i 's/^go 1\.26\.1$/go 1.25/' go.mod

# Remove unknown directives
sed -i '/^toolchain/d' go.mod

# Install project dependencies
go mod download

# Run tests
go test -race -tags=integration ./...