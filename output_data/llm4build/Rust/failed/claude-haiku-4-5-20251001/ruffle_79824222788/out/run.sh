#!/bin/bash
set -e

# Set environment variables
export FEATURES="lzma,jpegxr,imgtests"
export TEST_OPTS="--workspace --locked --no-fail-fast -j 4"
export RUFFLE_TEST_OPTS="--compile-mode=compile-and-verify"
export XDG_RUNTIME_DIR=""
export LIBCLANG_PATH=/usr/lib/x86_64-linux-gnu

# Ensure Rust toolchain is in PATH
export PATH="/root/.cargo/bin:${PATH}"

# Run tests with cargo nextest
echo "Running cargo nextest tests..."
cargo nextest run --profile ci --cargo-profile ci ${TEST_OPTS} --features ${FEATURES}

# Run doctests
echo "Running doctests..."
cargo test --doc --profile ci ${TEST_OPTS} --features ${FEATURES}

echo "All tests completed successfully!"