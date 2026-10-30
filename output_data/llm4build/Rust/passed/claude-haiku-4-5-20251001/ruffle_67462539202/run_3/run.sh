#!/bin/bash
set -e

# Set environment variables from the workflow
export FEATURES="lzma,jpegxr,imgtests"
export TEST_OPTS="--workspace --locked --no-fail-fast -j 4"
export CARGO_INCREMENTAL="1"
export CARGO_NET_GIT_FETCH_WITH_CLI="true"
export XDG_RUNTIME_DIR=""

# Install cargo-nextest with --locked flag
echo "Installing cargo-nextest..."
cargo install --locked cargo-nextest

# Run tests with cargo nextest
echo "Running cargo nextest tests..."
cargo nextest run --profile ci --cargo-profile ci ${TEST_OPTS} --features ${FEATURES}

# Run doctests
echo "Running doctests..."
cargo test --doc --profile ci ${TEST_OPTS} --features ${FEATURES}

echo "All tests completed successfully!"