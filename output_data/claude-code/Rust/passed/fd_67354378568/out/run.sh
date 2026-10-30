#!/usr/bin/env bash

set -e

TARGET="i686-unknown-linux-gnu"
BUILD_CMD="cargo"
name="fd"

echo "=== Show version information (Rust, cargo, GCC) ==="
gcc --version || true
rustup -V
rustup toolchain list
rustup default
cargo -V
rustc -V

echo ""
echo "=== Build ==="
$BUILD_CMD build --locked --release --target="${TARGET}"

echo ""
echo "=== Run tests ==="
$BUILD_CMD test --locked --target="${TARGET}"

echo ""
echo "=== Generate completions ==="
# For cross-compilation, we need to ensure the binary is available for make
# The Makefile expects target/release/fd, but we have target/i686-unknown-linux-gnu/release/fd
mkdir -p target/release
ln -sf ../i686-unknown-linux-gnu/release/fd target/release/fd
make completions

echo ""
echo "FINAL_STATUS = SUCCESS"
