#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
go run ./cmd/sqlc-test-setup install

# Start databases
# Switch to a non-root user for PostgreSQL
sudo -u postgres bash -c "go run ./cmd/sqlc-test-setup start"

# Run tests
gotestsum --junitfile junit.xml -- --tags=examples -timeout 20m -failfast ./... || true