#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Navigate to the cmd directory
cd cmd

# Install Go dependencies
go mod download

# Run tests with race detection
go test -race ./...

# Ensure all tests are executed, even if some fail
if [ $? -ne 0 ]; then
    echo "Some tests failed."
fi