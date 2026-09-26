#!/bin/bash

set -e

# Print commands for debugging
set -x

# Navigate to workspace
cd /workspace

# Build the project
echo "=== Building project ==="
cargo build

# Check formatting
echo "=== Checking code formatting ==="
cargo fmt -- --check

# Run clippy linter
echo "=== Running clippy ==="
cargo clippy --all-targets -- -Dclippy::all -D warnings

# Run tests
echo "=== Running tests ==="
cargo test

# Run benchmarks
echo "=== Running benchmarks ==="
cargo bench

echo "=== All checks passed ==="