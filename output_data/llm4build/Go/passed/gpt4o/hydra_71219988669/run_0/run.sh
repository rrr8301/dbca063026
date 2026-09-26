#!/bin/bash

# Start CockroachDB
cockroach start-single-node --insecure &

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
go mod tidy

# Run nancy
nancy --version v1.0.42

# Run golangci-lint
golangci-lint run --timeout 10m0s --new-from-rev=HEAD~1

# Run Go tests
go test -coverprofile coverage.out -failfast -timeout=20m ./...