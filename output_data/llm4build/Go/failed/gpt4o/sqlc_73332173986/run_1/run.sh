#!/bin/bash

# Install databases
go run ./cmd/sqlc-test-setup install

# Start databases
go run ./cmd/sqlc-test-setup start

# Run tests
gotestsum --junitfile junit.xml -- --tags=examples -timeout 20m -failfast ./...