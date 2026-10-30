#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Ensure go.mod specifies a valid Go version
sed -i 's/^go .*/go 1.21/' go.mod

# Install project dependencies
go mod tidy

# Run tests
# Adjust the package path if necessary
go test -v -parallel 8 ./...