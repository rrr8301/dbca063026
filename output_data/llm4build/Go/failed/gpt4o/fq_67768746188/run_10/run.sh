#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install Go dependencies
go mod tidy

# Run tests
make test || {
    echo "Some tests failed. Please check the logs for more details."
    exit 1
}