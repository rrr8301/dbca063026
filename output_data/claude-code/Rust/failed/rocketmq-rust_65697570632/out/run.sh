#!/usr/bin/env bash

set -e

source $HOME/.cargo/env

LIBCLANG_DIR=$(ls -d /usr/lib/llvm-*/lib | head -n 1)
export LIBCLANG_PATH=$LIBCLANG_DIR

cd /app

echo "=== Building (all features) ==="
cargo build --workspace --all-features

echo "=== Testing (all features) ==="
cargo test --workspace --all-features

echo "FINAL_STATUS = SUCCESS"
