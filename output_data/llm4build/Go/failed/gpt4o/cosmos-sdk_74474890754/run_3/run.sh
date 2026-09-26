#!/bin/bash

# Navigate to the project directory
cd /workspace/enterprise/poa

# Install Go dependencies
go mod download

# Check for changes and run tests
if [ -n "$(git diff --name-only HEAD^ HEAD | grep -E 'enterprise/poa/.*\.go|enterprise/poa/go\.mod|enterprise/poa/go\.sum')" ]; then
    go test -v -race -coverprofile=coverage.out -timeout 30m ./...
else
    echo "No relevant changes detected, skipping tests."
fi