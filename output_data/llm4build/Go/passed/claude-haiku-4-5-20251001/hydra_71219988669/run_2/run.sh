#!/bin/bash

set -e

# Set environment variables for database connections (optional for Docker standalone)
export TEST_DATABASE_POSTGRESQL="${TEST_DATABASE_POSTGRESQL:-postgres://postgres:secret@localhost:5432/postgres?sslmode=disable}"
export TEST_DATABASE_MYSQL="${TEST_DATABASE_MYSQL:-mysql://root:secret@(localhost:3306)/mysql?multiStatements=true&parseTime=true}"
export TEST_DATABASE_COCKROACHDB="${TEST_DATABASE_COCKROACHDB:-cockroach://root@localhost:26257/defaultdb?sslmode=disable}"

# Verify Go installation
go version

# Download Go dependencies
echo "Downloading Go dependencies..."
go mod download

# Generate go.list for nancy
echo "Generating go.list..."
go list -json > go.list

# Run golangci-lint
echo "Running golangci-lint..."
golangci-lint run --timeout 10m0s || true

# Run go tests with coverage
echo "Running go tests..."
go test -coverprofile coverage.out -failfast -timeout=20m ./...

echo "All tests completed!"