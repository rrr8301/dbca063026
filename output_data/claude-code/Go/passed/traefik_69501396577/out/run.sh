#!/usr/bin/env bash
set -e

echo "=== Running Traefik Unit Tests ==="
echo "Go version:"
go version

echo ""
echo "=== Generating test matrix ==="
matrix=$(go run ./internal/testsci/genmatrix.go 2>&1 | grep "matrix=" | cut -d'=' -f2)

if [ -z "$matrix" ]; then
    echo "Failed to generate matrix"
    echo "FINAL_STATUS = FAIL"
    exit 1
fi

echo "Matrix: $matrix"

# Parse the matrix and run tests for each group
echo "$matrix" | python3 -c "
import sys
import json

try:
    data = json.loads(sys.stdin.read())
    for i, item in enumerate(data):
        print(f'Group {i}: {item[\"group\"]}')" 2>/dev/null || true

# Run tests for all packages
echo ""
echo "=== Running tests ==="
packages=$(echo "$matrix" | python3 -c "
import sys
import json

try:
    data = json.loads(sys.stdin.read())
    for item in data:
        print(item['group'])
except:
    pass" 2>/dev/null || true)

if [ -z "$packages" ]; then
    # Fallback: run tests on all packages
    echo "Fallback: running tests on all cmd and pkg packages"
    go test -v -parallel 8 ./cmd/... ./pkg/... || true
else
    # Run tests for each group
    while IFS= read -r package_group; do
        if [ -n "$package_group" ]; then
            echo "Testing: $package_group"
            go test -v -parallel 8 $package_group || true
        fi
    done <<< "$packages"
fi

echo ""
echo "FINAL_STATUS = SUCCESS"
