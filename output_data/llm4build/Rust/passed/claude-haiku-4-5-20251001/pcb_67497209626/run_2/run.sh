#!/bin/bash

set -e

# Set environment variables for Cargo
export CARGO_TERM_COLOR=always
export CARGO_INCREMENTAL=0
export CARGO_PROFILE_TEST_DEBUG=0
export RUST_LOG=debug
export RUST_BACKTRACE=full
export KICAD_VERSION=9.0.7

# Ensure Rust is in PATH
export PATH="/root/.cargo/bin:${PATH}"

echo "=== Starting PCB Test Suite ==="

# Navigate to workspace root (assuming repo is cloned to /workspace)
cd /workspace

# Initialize test status flags
TEST_NEXTEST_FAILED=0
TEST_DOCTEST_FAILED=0

echo "=== Running Workspace Tests with Nextest ==="
if ! cargo nextest run --workspace --profile ci --locked; then
    echo "⚠ Nextest failed"
    TEST_NEXTEST_FAILED=1
fi

echo ""
echo "=== Running Doctests ==="
if ! cargo test --doc --workspace --locked; then
    echo "⚠ Doctests failed"
    TEST_DOCTEST_FAILED=1
fi

# Report results
echo ""
echo "=== Test Summary ==="
if [ "$TEST_NEXTEST_FAILED" -eq 0 ] && [ "$TEST_DOCTEST_FAILED" -eq 0 ]; then
    echo "✓ All tests passed"
    exit 0
else
    echo "✗ Some tests failed"
    [ "$TEST_NEXTEST_FAILED" -eq 1 ] && echo "  - Nextest failed"
    [ "$TEST_DOCTEST_FAILED" -eq 1 ] && echo "  - Doctests failed"
    exit 1
fi