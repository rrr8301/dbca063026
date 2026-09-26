#!/bin/bash

set -e

# Verify Go installation
go version

# Navigate to workspace
cd /workspace

# Run tests with coverage
go test -race -coverprofile=coverage.coverprofile -covermode=atomic ./...

echo "Tests completed successfully!"