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

echo "=== Running Workspace Tests with Nextest ==="
cargo nextest run --workspace --profile ci --locked || TEST_NEXTEST_FAILED=1

echo "=== Running Doctests ==="
cargo test --doc --workspace --locked || TEST_DOCTEST_FAILED=1

# Report results
echo ""
echo "=== Test Summary ==="
if [ -z "$TEST_NEXTEST_FAILED" ] && [ -z "$TEST_DOCTEST_FAILED" ]; then
    echo "✓ All tests passed"
    exit 0
else
    echo "✗ Some tests failed"
    [ -n "$TEST_NEXTEST_FAILED" ] && echo "  - Nextest failed"
    [ -n "$TEST_DOCTEST_FAILED" ] && echo "  - Doctests failed"
    exit 1
fi