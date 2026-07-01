#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
cd fiber
go mod download

# Run tests
gotestsum --format testname -- ./... -race -count=1 -coverprofile=coverage.txt -covermode=atomic -shuffle=on