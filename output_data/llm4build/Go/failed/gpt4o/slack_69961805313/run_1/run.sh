#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
go mod tidy

# Run tests
go test -v -race ./...

# Exit with the status of the last command
exit $?