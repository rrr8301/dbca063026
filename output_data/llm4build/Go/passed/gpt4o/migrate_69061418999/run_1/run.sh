#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Enable CGO for race detector
export CGO_ENABLED=1

# Create coverage directory
mkdir -p /tmp/coverage

# Install project dependencies
go mod download

# Run tests
make test COVERAGE_DIR=/tmp/coverage