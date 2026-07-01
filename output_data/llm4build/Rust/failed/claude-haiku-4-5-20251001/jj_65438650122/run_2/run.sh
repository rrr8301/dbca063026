#!/bin/bash

set -e

# Enable error output and color
export RUST_BACKTRACE=1
export CARGO_TERM_COLOR=always

echo "=== Building Jujutsu ==="
cargo build \
  --config .cargo/config-ci.toml \
  --workspace \
  --all-targets \
  --verbose \
  --all-features

echo "=== Running Tests ==="
cargo nextest run \
  --config .cargo/config-ci.toml \
  --workspace \
  --all-targets \
  --verbose \
  --profile ci \
  --all-features

echo "=== All tests completed ==="