#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
make verify-generate

# Run lint
make lint

# Build the project
make build

# Run tests
make test