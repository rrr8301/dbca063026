#!/usr/bin/env bash
set -e

export CARGO_TERM_COLOR=always
export CARGO_INCREMENTAL=0
export RUST_BACKTRACE=1

cd /app

echo "Rust version:"
rustc --version --verbose

echo "Patching Cargo.toml for nightly extension API..."
.github/other/patch-prebuilt.sh nightly

echo "Compiling tests..."
cargo test --no-run

echo "Running tests..."
cargo test

echo "FINAL_STATUS = SUCCESS"
