#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
make test-source-headers
go mod tidy -diff

# Run tests
make test-coverage