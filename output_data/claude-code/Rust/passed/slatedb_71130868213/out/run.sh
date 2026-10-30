#!/usr/bin/env bash
set -e

export RUSTFLAGS="-Dwarnings"

echo "=== Running Tests ==="
cargo nextest run --workspace --all-features --profile ci

echo "=== Running Doc Tests ==="
cargo test --doc --all-features

echo "=== Running DST Tests ==="
RUSTFLAGS="--cfg dst --cfg tokio_unstable" cargo nextest run -p slatedb-dst --all-features --profile dst

echo "FINAL_STATUS = SUCCESS"
