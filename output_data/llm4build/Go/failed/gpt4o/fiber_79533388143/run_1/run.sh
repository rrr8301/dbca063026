#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
go mod tidy

# Run tests
gotestsum --format testname -- ./... -race -count=1 -coverprofile=coverage.txt -covermode=atomic -shuffle=on