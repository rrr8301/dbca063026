#!/bin/bash

set -e

# Track test results
FAILED_TESTS=0

# Function to run tests and continue on failure
run_test() {
    local test_dir=$1
    echo "=========================================="
    echo "Running tests in: $test_dir"
    echo "=========================================="
    
    if cd "$test_dir" && cargo test --verbose; then
        echo "✓ Tests passed in $test_dir"
    else
        echo "✗ Tests failed in $test_dir"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    cd /workspace
}

# Run tests in each directory
run_test "macros"
run_test "core"
run_test "utils"
run_test "cli"

# Run tests in pkg/rust with specific features
echo "=========================================="
echo "Running tests in: pkg/rust"
echo "=========================================="

if cd /workspace/pkg/rust && cargo test --lib --bins --tests --examples --verbose --no-default-features --features "gluesql_memory_storage gluesql_sled_storage"; then
    echo "✓ Tests passed in pkg/rust"
else
    echo "✗ Tests failed in pkg/rust"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

cd /workspace

# Summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="

if [ $FAILED_TESTS -eq 0 ]; then
    echo "✓ All tests passed!"
    exit 0
else
    echo "✗ $FAILED_TESTS test suite(s) failed"
    exit 1
fi