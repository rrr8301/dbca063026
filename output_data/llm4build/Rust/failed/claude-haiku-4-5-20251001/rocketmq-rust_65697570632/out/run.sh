#!/bin/bash

set -e

# Source Rust environment
. $HOME/.cargo/env

# Export environment variables for this session
export CC=clang
export CXX=clang++
export LIBCLANG_PATH=$(ls -d /usr/lib/llvm-*/lib | head -n 1)
export CARGO_TERM_COLOR=always
export RUST_BACKTRACE=full
export CI=true
export CARGO_PROFILE_DEV_DEBUG=false
export CARGO_PROFILE_TEST_DEBUG=false
export CARGO_PROFILE_DEV_OPT_LEVEL=1
export CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false
export CARGO_TARGET_DIR=target
export ROCKSDB_DISABLE_JEMALLOC=1

echo "=== Rust Environment ==="
rustc --version
cargo --version
echo "CC: $CC"
echo "CXX: $CXX"
echo "LIBCLANG_PATH: $LIBCLANG_PATH"
echo ""

echo "=== Building (all features) ==="
cargo build --workspace --all-features
BUILD_EXIT=$?

echo ""
echo "=== Testing (all features) ==="
cargo test --workspace --all-features
TEST_EXIT=$?

echo ""
echo "=== Build & Test Summary ==="
if [ $BUILD_EXIT -eq 0 ]; then
    echo "✓ Build succeeded"
else
    echo "✗ Build failed with exit code $BUILD_EXIT"
fi

if [ $TEST_EXIT -eq 0 ]; then
    echo "✓ Tests passed"
else
    echo "✗ Tests failed with exit code $TEST_EXIT"
fi

# Exit with test result (most critical)
exit $TEST_EXIT