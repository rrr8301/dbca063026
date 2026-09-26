#!/bin/bash

set -euo pipefail

# Setup Go environment
export GOCACHE=/workspace/go-cache
export GOMODCACHE=/workspace/go-mod-cache
export GOPATH=/workspace/go-path
export GOTMPDIR=/workspace/go-tmp

mkdir -p "$GOCACHE" "$GOMODCACHE" "$GOPATH" "$GOTMPDIR"

# Run tests with PostgreSQL Database
# Assuming the test-go-pg action is a script or command
# Replace with the actual command if available
./scripts/test-go-pg.sh

# Ensure all tests are executed
exit 0