#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
echo "Checking for missing license headers..."
if ! make test-source-headers; then
    echo "Error: Some source files are missing license headers."
    echo "Please ensure all source files have the appropriate license headers."
    exit 1
fi

# Tidy Go modules
echo "Tidying Go modules..."
go mod tidy

# Run tests
echo "Running test coverage..."
if ! make test-coverage; then
    echo "Error: Test coverage failed."
    exit 1
fi