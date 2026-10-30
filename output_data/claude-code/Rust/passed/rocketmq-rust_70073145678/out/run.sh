#!/usr/bin/env bash

set -e

export PATH="/root/.cargo/bin:$PATH"
export LIBCLANG_PATH=$(ls -d /usr/lib/llvm-*/lib | head -n 1)

echo "Building (all features)..."
cargo build --workspace --all-features

echo "Testing (all features)..."
cargo test --workspace --all-features

echo ""
echo "FINAL_STATUS = SUCCESS"
