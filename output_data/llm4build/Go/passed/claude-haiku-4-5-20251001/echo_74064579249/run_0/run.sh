#!/bin/bash

set -e

# Activate Go environment
export PATH=/usr/local/go/bin:$PATH
export GOPATH=/home/testuser/go
export GOROOT=/usr/local/go

# Verify Go installation
go version

# Navigate to workspace
cd /workspace

# Run tests with coverage
go test -race --coverprofile=coverage.coverprofile --covermode=atomic ./...

echo "Tests completed successfully!"