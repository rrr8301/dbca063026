#!/usr/bin/env bash
set -e

export RUST_BACKTRACE=1
export CARGO_TERM_COLOR=always

cd /app

echo "Building project..."
cargo build \
  --config .cargo/config-ci.toml \
  --workspace \
  --all-targets \
  --verbose \
  --all-features

echo "Running tests..."
cargo nextest run \
  --config .cargo/config-ci.toml \
  --workspace \
  --all-targets \
  --verbose \
  --profile ci \
  --all-features

echo "FINAL_STATUS = SUCCESS"
