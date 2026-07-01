#!/bin/bash
set -e

# Activate Rust environment
export PATH="/root/.cargo/bin:${PATH}"

# Ensure rustup is available
rustup show

# Set environment variables for the test
export RUST_MIN_STACK=8388608
export CARGO_INCREMENTAL=0

# Navigate to crates directory and run tests
cd /workspace/crates

# Run tests excluding scenario_tests
echo "Running tests (excluding scenario_tests)..."
cargo test -- --skip scenario_tests::scenarios::tests

# Run scenario_tests with single job
echo "Running scenario_tests with single job..."
cargo test --jobs 1 scenario_tests::scenarios::tests

echo "All tests completed successfully!"