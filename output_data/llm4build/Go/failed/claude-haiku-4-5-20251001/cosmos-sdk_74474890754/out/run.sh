#!/bin/bash

set -e

# Navigate to the POA enterprise module
cd /workspace/enterprise/poa

# Run Go tests with race detector and coverage
go test -v -race -coverprofile=coverage.out -timeout 30m ./...

echo "Tests completed successfully"