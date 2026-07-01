#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Install databases
go run ./cmd/sqlc-test-setup install

# Start databases as a non-root user
sudo -u postgres go run ./cmd/sqlc-test-setup start

# Run tests
gotestsum --junitfile junit.xml -- --tags=examples -timeout 20m -failfast ./...