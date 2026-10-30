#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Print Go version
go version

# Install Go dependencies
go mod download

# Run coverage tests
set -e
make go.test.coverage || true

# Ensure all tests are executed
echo "All tests executed, even if some failed."