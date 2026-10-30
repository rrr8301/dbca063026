#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Enable CGO
export CGO_ENABLED=1

# Navigate to the correct directory
# Assuming the correct directory is /app, adjust if necessary
cd /app

# Ensure the coverage directory exists
mkdir -p /tmp/coverage

# Install Go dependencies
go mod download

# Run tests
make test COVERAGE_DIR=/tmp/coverage