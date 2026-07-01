#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Print each command before executing it
set -x

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Verify Go installation
go version

# Install project dependencies
# Assuming dependencies are managed via go.mod, so no additional steps needed

# Run tests
# Ensure all tests are executed, even if some fail
set +e
go test -shuffle=on ./...
go test -race -shuffle=on ./...
set -e