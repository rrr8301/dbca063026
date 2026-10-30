#!/bin/bash

set -e

# Print Rust and Cargo versions for debugging
echo "=== Rust Toolchain Info ==="
rustc --version
cargo --version
just --version
echo ""

# Install project dependencies (if needed via Cargo)
echo "=== Building Project ==="
cargo build --verbose

# Run all tests
echo ""
echo "=== Running Tests ==="
just test-all

echo ""
echo "=== All Tests Completed Successfully ==="