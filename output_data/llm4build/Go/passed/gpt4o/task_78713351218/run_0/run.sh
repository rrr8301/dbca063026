#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
# Assuming dependencies are managed within the Go project itself

# Run tests
go run ./cmd/task test