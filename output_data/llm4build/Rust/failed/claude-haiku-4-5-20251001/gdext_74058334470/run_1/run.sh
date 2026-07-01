#!/bin/bash
set -e

# Print Rust version for debugging
echo "=== Rust Version ==="
rustc --version --verbose
cargo --version

# Patch Cargo.toml to use nightly extension API
echo "=== Patching Cargo.toml for nightly ==="
.github/other/patch-prebuilt.sh nightly

# Compile tests
echo "=== Compiling tests ==="
cargo test --no-run

# Run tests
echo "=== Running tests ==="
cargo test

# Run doctests with minimal feature set
echo "=== Running doctests with minimal features ==="
cargo test --doc --no-default-features

echo "=== All tests completed successfully ==="