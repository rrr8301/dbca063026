#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Build the project
go run build.go

# Run tests
go run build.go test | go-test-json-to-loki