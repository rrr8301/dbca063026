#!/bin/bash
set -e

# Enable error handling but continue on test failures
trap 'TEST_FAILED=1' ERR

TEST_FAILED=0

# Set environment variables
export CARGO_TERM_COLOR=always
export MISE_TRUSTED_CONFIG_PATHS=/workspace
export MISE_EXPERIMENTAL=1
export MISE_LOCKFILE=1
export RUST_BACKTRACE=1
export GITHUB_TOKEN="${GITHUB_TOKEN:-}"
export FORGEJO_TOKEN="${FORGEJO_TOKEN:-}"

echo "=== Setting Rust to nightly ==="
rustup default nightly
rustup show

echo "=== Building project with all features ==="
cd /workspace
cargo build --all-features

echo "=== Adding debug binaries to PATH ==="
export PATH="/workspace/target/debug:${PATH}"

echo "=== Installing mise ==="
curl https://mise.run | sh
export PATH="/root/.local/bin:${PATH}"

echo "=== Installing mise tools ==="
mise install

echo "=== Running tests ==="
if ! mise run test; then
    TEST_FAILED=1
fi

echo "=== Test execution completed ==="
if [ $TEST_FAILED -eq 1 ]; then
    echo "Some tests failed, but continuing..."
    exit 1
fi

exit 0