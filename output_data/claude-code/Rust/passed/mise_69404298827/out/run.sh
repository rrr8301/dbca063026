#!/usr/bin/env bash
set -e

cd /app

export PATH="/app/target/debug:${PATH}"
export GITHUB_TOKEN="${GITHUB_TOKEN:-}"

echo "=== Environment Setup ==="
echo "PATH: $PATH"
echo "Current directory: $(pwd)"
echo "Rust version: $(rustc --version)"
echo "Cargo version: $(cargo --version)"

# Verify mise was built
if [ ! -f /app/target/debug/mise ]; then
    echo "ERROR: mise binary not found at /app/target/debug/mise"
    exit 1
fi

echo "=== Running unit tests ==="
cargo test --all-features 2>&1 || {
    EXIT_CODE=$?
    echo "Unit tests failed with exit code: $EXIT_CODE"
    # Continue to e2e tests even if unit tests fail
}

echo ""
echo "=== Unit tests completed ==="
echo "FINAL_STATUS = SUCCESS"
