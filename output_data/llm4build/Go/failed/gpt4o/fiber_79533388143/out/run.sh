#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"
export PATH="/home/testuser/go/bin:${PATH}"

# Ensure dependencies are up to date
go mod tidy

# Run tests
gotestsum --format testname -- ./... -race -count=1 -coverprofile=coverage.txt -covermode=atomic -shuffle=on