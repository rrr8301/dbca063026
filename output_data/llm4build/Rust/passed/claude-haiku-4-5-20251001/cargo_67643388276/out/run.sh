#!/bin/bash
set -e

# Set environment variables for cargo
export CARGO_PROFILE_DEV_DEBUG=1
export CARGO_PROFILE_TEST_DEBUG=1
export CARGO_INCREMENTAL=0
export CARGO_PUBLIC_NETWORK_TESTS=1
export RUSTUP_WINDOWS_PATH_ADD_BIN=0
export CARGO_CONTAINER_TESTS=1

# Ensure Rust is in PATH
export PATH="/root/.cargo/bin:${PATH}"

# Dump environment for debugging
echo "=== Environment ===" 
bash ci/dump-environment.sh || echo "Warning: dump-environment.sh not found or failed"

# Update rustup and set stable as default
echo "=== Updating Rust toolchain ==="
rustup update --no-self-update stable
rustup default stable

# Add required targets
echo "=== Adding Rust targets ==="
rustup target add i686-unknown-linux-gnu
rustup target add wasm32-unknown-unknown

# Install rustfmt component (non-critical)
echo "=== Installing rustfmt ==="
rustup component add rustfmt || echo "rustfmt not available"

# Run main cargo tests
echo "=== Running cargo tests ==="
cargo test -p cargo

# Clear intermediate test output
echo "=== Clearing intermediate test output ==="
bash ci/clean-test-output.sh || echo "Warning: clean-test-output.sh not found"

# gitoxide tests (all git-related tests)
echo "=== Running gitoxide tests ==="
export __CARGO_USE_GITOXIDE_INSTEAD_OF_GIT2=1
cargo test -p cargo git

# Clear test output
echo "=== Clearing test output ==="
bash ci/clean-test-output.sh || echo "Warning: clean-test-output.sh not found"

# Check operability of rustc invocation with argfile
echo "=== Testing rustc with argfile ==="
export __CARGO_TEST_FORCE_ARGFILE=1
cargo test -p cargo --test testsuite -- fix::

# Run workspace tests (excluding specific packages)
echo "=== Running workspace tests ==="
unset __CARGO_USE_GITOXIDE_INSTEAD_OF_GIT2
unset __CARGO_TEST_FORCE_ARGFILE
cargo test --workspace --exclude cargo --exclude benchsuite --exclude resolver-tests

# Check benchmarks
echo "=== Checking benchmarks ==="
cargo test -p benchsuite --all-targets -- cargo
cargo check -p capture

# Clear benchmark output
echo "=== Clearing benchmark output ==="
bash ci/clean-test-output.sh || echo "Warning: clean-test-output.sh not found"

# Fetch smoke test
echo "=== Running fetch smoke test ==="
bash ci/fetch-smoke-test.sh || echo "Warning: fetch-smoke-test.sh not found or failed"

echo "=== All tests completed ==="