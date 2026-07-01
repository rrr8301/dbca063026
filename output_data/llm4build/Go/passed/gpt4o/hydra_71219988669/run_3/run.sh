#!/bin/bash

# Start CockroachDB
cockroach start-single-node --insecure --listen-addr=localhost &

# Wait for CockroachDB to start
sleep 10

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
go mod tidy

# Run nancy
/usr/local/go/bin/nancy --version || echo "Nancy installation failed or path is incorrect."

# Run golangci-lint
/usr/local/bin/golangci-lint run --timeout 10m0s --new-from-rev=HEAD~1

# Run Go tests
go test -coverprofile coverage.out -failfast -timeout=20m ./...