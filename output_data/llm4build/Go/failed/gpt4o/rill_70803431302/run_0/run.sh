#!/bin/bash

# Set Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Check Go formatting
test -z $(gofmt -l .)

# Run Go tests
go test -timeout 30m -short -v ./...