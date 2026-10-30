#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
make test-source-headers || { echo "License headers missing"; exit 1; }
go mod tidy

# Run tests
make test-coverage || { echo "Test coverage failed"; exit 1; }