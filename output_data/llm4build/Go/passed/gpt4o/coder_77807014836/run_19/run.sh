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
if [ -f ./scripts/test-go-pg.sh ]; then
    ./scripts/test-go-pg.sh
else
    echo "Error: ./scripts/test-go-pg.sh not found."
    exit 1
fi

# Ensure all tests are executed
exit 0