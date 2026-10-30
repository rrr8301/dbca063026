#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Navigate to the cmd directory
cd cmd

# Check if go.mod exists and remove unsupported directives
if [ -f go.mod ]; then
    # Remove unsupported directives like 'toolchain'
    sed -i '/^toolchain/d' go.mod
fi

# Install Go dependencies
go mod tidy

# Run tests with race detection
go test -race ./...

# Ensure all tests are executed, even if some fail
if [ $? -ne 0 ]; then
    echo "Some tests failed."
fi