#!/bin/bash

# Activate Go environment
export PATH=$PATH:/usr/local/go/bin

# Install project dependencies
# Assuming a Makefile or similar is used for dependency management
make install

# Run tests with PostgreSQL Database
# The exact command is not provided, so we assume a placeholder command
# Replace with the actual test command from the `.github/actions/test-go-pg` action
echo "Running tests with PostgreSQL Database..."
# Placeholder for actual test command
# go test ./... -p 8 -count=1

# Ensure all tests are executed
set +e
# Example test command
go test ./... -p 8 -count=1
set -e