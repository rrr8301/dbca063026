#!/bin/bash

# Set environment variables
export GOFLAGS="-buildvcs=false -tags=next"

# Install Go dependencies
go mod download

# Run linting
if [ -f /app/bin/golangci-lint ]; then
    /app/bin/golangci-lint run -v ./...
else
    echo "golangci-lint not found, skipping linting."
fi

# Run build and tests
make test