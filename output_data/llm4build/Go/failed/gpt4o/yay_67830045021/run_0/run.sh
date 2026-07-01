#!/bin/bash

# Set environment variables
export GOFLAGS="-buildvcs=false -tags=next"

# Install Go dependencies
go mod download

# Run linting
/app/bin/golangci-lint run -v ./...

# Run build and tests
make test