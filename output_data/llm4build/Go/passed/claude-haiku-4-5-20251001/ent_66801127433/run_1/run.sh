#!/bin/bash

set -e

# Track test failures
FAILED=0

# Function to run tests in a directory
run_tests() {
    local dir=$1
    echo "=========================================="
    echo "Running tests in: $dir"
    echo "=========================================="
    
    if [ -d "$dir" ]; then
        cd "$dir"
        if ! go test -race ./...; then
            FAILED=$((FAILED + 1))
            echo "FAILED: Tests in $dir failed"
        fi
        cd - > /dev/null
    else
        echo "WARNING: Directory $dir not found, skipping"
    fi
    echo ""
}

# Run tests in all specified directories
run_tests "cmd"
run_tests "dialect"
run_tests "schema"
run_tests "entc/load"
run_tests "entc/gen"
run_tests "examples"

# Summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
if [ $FAILED -eq 0 ]; then
    echo "All test suites passed!"
    exit 0
else
    echo "FAILED: $FAILED test suite(s) failed"
    exit 1
fi