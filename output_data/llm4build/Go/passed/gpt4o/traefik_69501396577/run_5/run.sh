#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Ensure go.mod specifies a valid Go version
sed -i 's/^go .*/go 1.20/' go.mod

# Install project dependencies
go mod tidy

# Run tests
go test -v -parallel 8 github.com/traefik/traefik/v3/pkg/config/label github.com/traefik/traefik/v3/pkg/config