#!/usr/bin/env bash

set -e

cd /app

echo "Patching Cargo.toml to use nightly extension API..."
.github/other/patch-prebuilt.sh nightly

echo "Setting Rust environment variables..."
export CARGO_TERM_COLOR=always
export CARGO_INCREMENTAL=0
export RUST_BACKTRACE=1

echo "Compiling tests..."
cargo test --no-run

echo "Running tests..."
cargo test

echo "FINAL_STATUS = SUCCESS"
