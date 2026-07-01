#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "Go could not be found"
    exit 1
fi

# Install project dependencies
go mod download

# Run tests
go test -v -parallel 8 ./pkg/config/label ./pkg/config