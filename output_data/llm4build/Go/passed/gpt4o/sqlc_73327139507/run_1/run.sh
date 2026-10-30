#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
go run ./cmd/sqlc-test-setup install

# Start databases
go run ./cmd/sqlc-test-setup start

# Run tests
gotestsum --junitfile junit.xml -- --tags=examples -timeout 20m -failfast ./... || true