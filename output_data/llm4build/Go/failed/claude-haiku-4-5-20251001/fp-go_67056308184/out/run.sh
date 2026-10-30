#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Run Go tests with race detector, coverage, and all packages
go mod tidy
go test -race -coverprofile=coverage.txt -covermode=atomic -coverpkg=./... ./...

echo "Tests completed successfully. Coverage report: coverage.txt"