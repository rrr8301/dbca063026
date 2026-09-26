#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Navigate to the project directory
cd /app

# Install Go dependencies
go mod tidy

# Run tests with coverage
go test -race -coverprofile=coverage.txt -covermode=atomic -coverpkg=./... ./...

# Note: Coverage upload to Coveralls is skipped