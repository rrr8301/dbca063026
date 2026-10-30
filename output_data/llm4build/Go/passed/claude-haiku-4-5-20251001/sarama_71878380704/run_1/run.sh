#!/bin/bash
set -e

# Print environment info
echo "=== Go Version ==="
go version

echo "=== Go Environment ==="
go env

# Navigate to workspace
cd /workspace

# Install project dependencies (if go.mod exists)
if [ -f go.mod ]; then
    echo "=== Installing Go Dependencies ==="
    go mod download
    go mod verify
fi

# Run unit tests
echo "=== Running Unit Tests ==="
make test

# Report test results (if tparse output exists)
if [ -f _test/unittests.json ]; then
    echo "=== Test Results Summary ==="
    go run github.com/mfridman/tparse@v0.18.0 -all -format markdown -file _test/unittests.json || true
fi

# Report per-function code coverage (if coverage profile exists)
if [ -f profile.out ]; then
    echo "=== Per-Function Code Coverage ==="
    go tool cover -func=profile.out || true
fi

echo "=== Tests Complete ==="