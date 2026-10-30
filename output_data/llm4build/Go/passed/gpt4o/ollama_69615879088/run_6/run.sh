#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install tscriptify
go install github.com/tkrajina/typescriptify-golang-structs/tscriptify@latest

# Run UI tests if package.json exists
if [ -f /app/ui/app/package.json ]; then
    cd /app/ui/app
    npm test || true
fi

# Run go generate
cd /app
go generate ./...

# Run go tests
go test -count=1 -benchtime=1x ./... || true

# Run golangci-lint
golangci-lint run --new-from-rev=HEAD~1 || true