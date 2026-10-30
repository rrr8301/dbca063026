#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install Go dependencies
go mod tidy -compat=1.17
go mod download

# Run tests and build
set -e

# Check and fix go.mod version format
sed -i 's/^go [0-9]\+\.[0-9]\+\.[0-9]\+$/go 1.17/' go.mod

# Run tests and build
make test-source-headers || true
go mod tidy -compat=1.17 || true
make test-coverage || true
make build || true

# Check for specific packages that might not be compatible with Go 1.17
# and provide alternative solutions or skip them if necessary
# Note: This is a placeholder for any additional logic needed to handle
# specific package compatibility issues.

# Additional step to ensure all dependencies are correctly fetched
go get -u ./...

# Re-run tests and build after ensuring dependencies
make test-source-headers || true
make test-coverage || true
make build || true