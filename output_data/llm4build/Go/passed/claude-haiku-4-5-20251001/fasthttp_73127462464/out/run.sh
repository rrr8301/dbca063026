#!/bin/bash

set -e

# Print Go version for verification
echo "=== Go Version ==="
go version

# Navigate to workspace
cd /workspace

# Clone repository if not already present
if [ ! -d ".git" ]; then
    echo "=== Cloning Repository ==="
    git clone https://github.com/valyala/fasthttp.git .
fi

# Update to latest changes
git fetch origin
git checkout master

echo "=== Running Tests with Shuffle ==="
go test -shuffle=on ./... || TEST_SHUFFLE_FAILED=1

echo "=== Running Tests with Race Detector ==="
go test -race -shuffle=on ./... || TEST_RACE_FAILED=1

# Report results
if [ "$TEST_SHUFFLE_FAILED" = "1" ] || [ "$TEST_RACE_FAILED" = "1" ]; then
    echo "=== Some Tests Failed ==="
    exit 1
fi

echo "=== All Tests Passed ==="
exit 0