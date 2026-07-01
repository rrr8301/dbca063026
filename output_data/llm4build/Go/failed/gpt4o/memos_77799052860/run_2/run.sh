#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Enable cgo
export CGO_ENABLED=1

# Run tests
go test -v -race -coverprofile=coverage.out -covermode=atomic ./server/...