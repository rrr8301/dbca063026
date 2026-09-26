#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Navigate to the app directory
cd /app

# Check and correct the Go version in go.mod if necessary
sed -i 's/^go [0-9]\+\.[0-9]\+\.[0-9]\+/go 1.20/' go.mod

# Run go generate
go generate ./...

# Run go tests
go test -count=1 -benchtime=1x ./...