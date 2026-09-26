#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
go mod download

# Run build
make all

# Run vet
make vet

# Run golangci-lint
golangci-lint run

# Run tests
make test

# Run end-to-end tests
make e2evv

# Build test mobile
make build-test-mobile