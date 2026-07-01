#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install tscriptify
go install github.com/tkrajina/typescriptify-golang-structs/tscriptify@latest

# Run UI tests
cd /app/ui/app
if [ -f package.json ]; then
    npm test || true
else
    echo "Skipping npm test as package.json is not found"
fi

# Run go generate
cd /app
go generate ./... || true

# Run go tests
go test -count=1 -benchtime=1x ./... || true

# Run golangci-lint
$(go env GOPATH)/bin/golangci-lint run --new-from-rev=HEAD~1 || true