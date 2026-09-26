#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Ensure we're on the correct branch/commit (if needed)
# This assumes the repo is already copied; if cloning is needed:
# git clone <repo-url> /workspace
# cd /workspace
# git checkout <branch>
# git reset --hard <commit-sha>

# Run Go tests with race detector, coverage, and all packages
go mod tidy
go test -race -coverprofile=coverage.txt -covermode=atomic -coverpkg=./... ./...

echo "Tests completed successfully. Coverage report: coverage.txt"