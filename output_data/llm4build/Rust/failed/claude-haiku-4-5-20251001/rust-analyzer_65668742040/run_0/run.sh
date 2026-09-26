#!/bin/bash

set -e

# Print environment info
echo "=== Rust Toolchain Info ==="
rustc --version
cargo --version
rustup toolchain list

# Install nextest
echo "=== Installing nextest ==="
cargo install cargo-nextest --locked

# Install cargo-machete
echo "=== Installing cargo-machete ==="
cargo install cargo-machete --locked

# Run codegen checks
echo "=== Running codegen checks ==="
cargo codegen --check

# Run tests with nextest
echo "=== Running tests with nextest ==="
cargo nextest run --no-fail-fast --hide-progress-bar --status-level fail || TEST_FAILED=1

# Run cargo-machete
echo "=== Running cargo-machete ==="
cargo machete || MACHETE_FAILED=1

# Report results
echo "=== Test Summary ==="
if [ -n "$TEST_FAILED" ]; then
    echo "⚠️  Tests failed"
fi
if [ -n "$MACHETE_FAILED" ]; then
    echo "⚠️  cargo-machete found issues"
fi

# Exit with failure if any checks failed
if [ -n "$TEST_FAILED" ] || [ -n "$MACHETE_FAILED" ]; then
    exit 1
fi

echo "✅ All checks passed"
exit 0