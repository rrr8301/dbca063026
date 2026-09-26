#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Run tests
go test -v -race -coverprofile=coverage.out -covermode=atomic ./server/...