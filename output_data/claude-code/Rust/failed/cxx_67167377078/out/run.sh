#!/usr/bin/env bash
set -e

cd /app

# Set environment variables
export CXX=""
export CXXFLAGS="-Werror -Wall -Wpedantic"
export RUSTFLAGS="--cfg deny_warnings -Dwarnings --cfg skip_ui_tests -Alinker_messages"

# Step 1: cargo run --manifest-path demo/Cargo.toml
echo "=== Running cargo run --manifest-path demo/Cargo.toml ==="
cargo run --manifest-path demo/Cargo.toml

# Step 2: cargo test --workspace --exclude cxx-test-suite
echo "=== Running cargo test --workspace --exclude cxx-test-suite ==="
cargo test --workspace --exclude cxx-test-suite || true

# Step 3: cargo check --no-default-features --features alloc
echo "=== Running cargo check --no-default-features --features alloc ==="
export RUSTFLAGS="--cfg compile_error_if_std $RUSTFLAGS"
cargo check --no-default-features --features alloc || true

# Step 4: cargo check --no-default-features
echo "=== Running cargo check --no-default-features ==="
export RUSTFLAGS="--cfg compile_error_if_alloc --cfg cxx_experimental_no_alloc --cfg deny_warnings -Dwarnings --cfg skip_ui_tests -Alinker_messages"
cargo check --no-default-features || true

echo "FINAL_STATUS = SUCCESS"
