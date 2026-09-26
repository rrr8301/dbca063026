#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install tscriptify
go install github.com/tkrajina/typescriptify-golang-structs/tscriptify@latest

# Run UI tests
cd /app/ui/app
npm test || true

# Run go generate
cd /app
go generate ./...

# Run go tests
go test -count=1 -benchtime=1x ./... || true

# Run golangci-lint
golangci-lint run --new-from-rev=HEAD~1 || true