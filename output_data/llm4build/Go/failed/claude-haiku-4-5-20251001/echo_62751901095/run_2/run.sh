#!/bin/sh
set -e

# Navigate to workspace
cd /workspace

# Run tests with coverage and race detector
go test -race --coverprofile=coverage.coverprofile --covermode=atomic ./...

echo "Tests completed successfully"