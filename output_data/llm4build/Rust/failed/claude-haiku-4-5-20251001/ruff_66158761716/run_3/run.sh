#!/bin/bash
set -e

# Ensure we're in the workspace
cd /workspace

# Source Rust environment
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Display Rust toolchain info
echo "=== Rust Toolchain ==="
rustup show

# Run cargo tests with insta and nextest
echo "=== Running cargo insta tests ==="
cargo insta test --all-features --unreferenced reject --test-runner nextest

# Dogfood ty on py-fuzzer
echo "=== Dogfood ty on py-fuzzer ==="
uv run --project=./python/py-fuzzer cargo run -p ty check --project=./python/py-fuzzer

# Dogfood ty on the scripts directory
echo "=== Dogfood ty on scripts ==="
uv run --project=./scripts cargo run -p ty check --project=./scripts

# Dogfood ty on ty_benchmark
echo "=== Dogfood ty on ty_benchmark ==="
uv run --project=./scripts/ty_benchmark cargo run -p ty check --project=./scripts/ty_benchmark

# Generate documentation (all crates)
echo "=== Generating documentation (all crates) ==="
cargo doc --all --no-deps

# Generate documentation (specific crates with private items)
echo "=== Generating documentation (specific crates with private items) ==="
RUSTDOCFLAGS="-D warnings" cargo doc --no-deps -p ty_python_semantic -p ty -p ty_test -p ruff_db -p ruff_python_formatter --document-private-items

echo "=== All tests completed successfully ==="