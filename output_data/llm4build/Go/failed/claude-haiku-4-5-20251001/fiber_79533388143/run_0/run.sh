#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Run tests with gotestsum
go run gotest.tools/gotestsum@latest -f testname -- ./... -race -count=1 -coverprofile=coverage.txt -covermode=atomic -shuffle=on