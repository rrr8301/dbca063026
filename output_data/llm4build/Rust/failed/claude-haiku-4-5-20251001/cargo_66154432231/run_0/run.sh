#!/bin/bash
set -e

# Activate Rust environment
export PATH="/root/.cargo/bin:${PATH}"

# Update Rust toolchain to stable
rustup update --no-self-update stable
rustup default stable

# Add wasm32 target
rustup target add wasm32-unknown-unknown

# Add rustfmt component (non-fatal if unavailable)
rustup component add rustfmt || echo "rustfmt not available"

# Dump environment for diagnostics
bash ci/dump-environment.sh

# Test cargo package
echo "=== Testing cargo package ==="
cargo test -p cargo

# Clear intermediate test output
bash ci/clean-test-output.sh

# gitoxide tests (all git-related tests)
echo "=== Running gitoxide tests ==="
__CARGO_USE_GITOXIDE_INSTEAD_OF_GIT2=1 cargo test -p cargo git

# Clear test output
bash ci/clean-test-output.sh

# Check operability of rustc invocation with argfile
echo "=== Testing argfile support ==="
__CARGO_TEST_FORCE_ARGFILE=1 cargo test -p cargo --test testsuite -- fix::

# Test workspace (excluding certain packages)
echo "=== Testing workspace ==="
cargo test --workspace --exclude cargo --exclude benchsuite --exclude resolver-tests

# Check benchmarks
echo "=== Checking benchmarks ==="
cargo test -p benchsuite --all-targets -- cargo
cargo check -p capture

# Clear benchmark output
bash ci/clean-test-output.sh

# Fetch smoke test
echo "=== Running smoke test ==="
bash ci/fetch-smoke-test.sh

echo "=== All tests completed successfully ==="