#!/bin/bash
set -e

# Activate Rust environment
export PATH="/home/testuser/.cargo/bin:${PATH}"

# Ensure rustup is available
rustup show

# Set environment variables for the test
export RUST_MIN_STACK=8388608
export CARGO_INCREMENTAL=0

# Start gnome-keyring daemon and unlock it
gnome-keyring-daemon --components=secrets --daemonize --unlock <<< 'foobar'

# Navigate to crates directory and run tests
cd /workspace/crates

# Run all tests except scenario_tests::scenarios::tests
echo "Running tests (excluding scenario_tests::scenarios::tests)..."
cargo test -- --skip scenario_tests::scenarios::tests

# Run scenario_tests::scenarios::tests with single job
echo "Running scenario_tests::scenarios::tests with --jobs 1..."
cargo test --jobs 1 scenario_tests::scenarios::tests

echo "All tests completed successfully!"