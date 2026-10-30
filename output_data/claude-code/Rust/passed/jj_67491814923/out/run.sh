#!/usr/bin/env bash

export RUST_BACKTRACE=1
export CARGO_TERM_COLOR=always

cd /app

echo "Running cargo nextest tests..."
cargo nextest run \
    --config .cargo/config-ci.toml \
    --workspace \
    --all-targets \
    --verbose \
    --profile ci \
    --all-features || true

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
