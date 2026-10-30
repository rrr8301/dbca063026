#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install Go dependencies
go mod tidy
go mod download

# Run tests and build
set -e
make test-source-headers || true
go mod tidy || true
make test-coverage || true
make build || true