#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Print Go version
go version

# Install Go dependencies
go mod tidy

# Run coverage tests
make go.test.coverage

# Ensure all tests are executed
echo "All tests executed successfully."