#!/bin/bash

# Start CockroachDB
cockroach start-single-node --insecure --listen-addr=localhost &

# Wait for CockroachDB to start
sleep 10

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Check and fix go.mod file
if ! go mod tidy; then
  echo "Error in go.mod file. Please check the file for syntax errors."
  exit 1
fi

# Run nancy
if ! nancy --version; then
  echo "Nancy installation failed or path is incorrect."
  exit 1
fi

# Run golangci-lint
golangci-lint run --timeout 10m0s --new-from-rev=HEAD~1

# Run Go tests
go test -coverprofile coverage.out -failfast -timeout=20m ./...