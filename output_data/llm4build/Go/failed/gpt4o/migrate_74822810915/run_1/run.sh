#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Navigate to the migrate directory
cd migrate

# Install Go dependencies
go mod download

# Run tests
make test COVERAGE_DIR=/tmp/coverage