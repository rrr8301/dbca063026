#!/bin/bash

# Navigate to the project directory
cd /workspace/enterprise/poa

# Install Go dependencies
go mod download

# Run tests if there are changes
if [ -n "$(git diff --name-only HEAD^ HEAD | grep -E 'enterprise/poa/.*\.go|enterprise/poa/go\.mod|enterprise/poa/go\.sum')" ]; then
    go test -v -race -coverprofile=coverage.out -timeout 30m ./...
fi