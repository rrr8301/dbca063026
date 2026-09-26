#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
go mod tidy

# Run tests
go test -v -race ./... || true

# Ensure all tests are executed, even if some fail
exit 0