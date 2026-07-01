#!/bin/bash

set -e

# Set environment variables
export CXX=g++
export CXXFLAGS='-Werror -Wall -Wpedantic'
export RUSTFLAGS='--cfg deny_warnings -Dwarnings'

echo "=== Rust Stable Test Suite ==="
echo "Rust version:"
rustc --version
echo "Cargo version:"
cargo --version
echo "C++ compiler:"
$CXX --version
echo ""

# Track test failures but continue execution
FAILED=0

# Run demo
echo "=== Running demo ==="
if cargo run --manifest-path demo/Cargo.toml; then
    echo "✓ Demo passed"
else
    echo "✗ Demo failed"
    FAILED=1
fi
echo ""

# Run workspace tests (excluding cxx-test-suite)
echo "=== Running workspace tests ==="
if cargo test --workspace --exclude cxx-test-suite; then
    echo "✓ Workspace tests passed"
else
    echo "✗ Workspace tests failed"
    FAILED=1
fi
echo ""

# Check with --no-default-features --features alloc
echo "=== Checking with --no-default-features --features alloc ==="
export RUSTFLAGS='--cfg compile_error_if_std --cfg deny_warnings -Dwarnings'
if cargo check --no-default-features --features alloc; then
    echo "✓ Check with alloc feature passed"
else
    echo "✗ Check with alloc feature failed"
    FAILED=1
fi
echo ""

# Check with --no-default-features
echo "=== Checking with --no-default-features ==="
export RUSTFLAGS='--cfg compile_error_if_alloc --cfg cxx_experimental_no_alloc --cfg deny_warnings -Dwarnings'
if cargo check --no-default-features; then
    echo "✓ Check without default features passed"
else
    echo "✗ Check without default features failed"
    FAILED=1
fi
echo ""

# Exit with appropriate code
if [ $FAILED -eq 0 ]; then
    echo "=== All tests passed ==="
    exit 0
else
    echo "=== Some tests failed ==="
    exit 1
fi