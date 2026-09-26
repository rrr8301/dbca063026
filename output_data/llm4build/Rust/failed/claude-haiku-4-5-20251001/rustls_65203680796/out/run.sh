#!/bin/bash
set -e

# Ensure Rust toolchain is available
. $HOME/.cargo/env

# Display Rust version info
echo "=== Rust Toolchain Info ==="
rustc --version
cargo --version
rustup show

# Build (debug; default features)
echo ""
echo "=== Building (debug; default features) ==="
cargo build --locked

# Test (release; all features)
echo ""
echo "=== Testing (release; all features) ==="
cargo test --locked --release --all-features --all-targets

echo ""
echo "=== All tests passed ==="