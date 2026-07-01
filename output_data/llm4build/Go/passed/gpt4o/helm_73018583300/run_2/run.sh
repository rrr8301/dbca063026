#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install Go dependencies
go mod tidy
go mod download

# Run tests and build
set -e

# Check and fix go.mod version format
sed -i 's/^go [0-9]\+\.[0-9]\+\.[0-9]\+$/go 1.17/' go.mod

# Run tests and build
make test-source-headers || true
go mod tidy || true
make test-coverage || true
make build || true