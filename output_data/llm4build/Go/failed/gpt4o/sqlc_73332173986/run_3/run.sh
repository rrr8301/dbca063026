#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Install databases
go run ./cmd/sqlc-test-setup install

# Start databases as a non-root user
# Ensure the PATH is correctly set for sudo
sudo -E -u postgres env "PATH=$PATH" go run ./cmd/sqlc-test-setup start

# Run tests
gotestsum --junitfile junit.xml -- --tags=examples -timeout 20m -failfast ./...