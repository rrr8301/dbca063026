#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Navigate to the workspace directory
cd /workspace

# Install project dependencies
# Assuming dependencies are managed within the Go project itself

# Run tests
go test ./...