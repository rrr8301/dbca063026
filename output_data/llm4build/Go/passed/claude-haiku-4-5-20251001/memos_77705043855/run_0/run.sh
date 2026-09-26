#!/bin/bash
set -e

# Set test environment variable
export DRIVER=sqlite

# Run Go tests with coverage
go test -v -race -coverprofile=coverage.out -covermode=atomic ./server/...

echo "Tests completed successfully!"