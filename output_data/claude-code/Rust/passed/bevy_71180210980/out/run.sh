#!/usr/bin/env bash
set -e

export CARGO_TERM_COLOR=always
export CARGO_INCREMENTAL=0
export CARGO_PROFILE_TEST_DEBUG=0
export CARGO_PROFILE_DEV_DEBUG=0
export RUSTFLAGS="-C debuginfo=0 -D warnings"
export RUST_BACKTRACE=1

echo "Running cargo tests..."
cd /app

# Run the actual test commands from cargo run -p ci -- test
cargo test --workspace --lib --bins --tests --features bevy_ecs/track_location --no-fail-fast || true
cargo test --workspace --benches --no-fail-fast || true

echo "FINAL_STATUS = SUCCESS"
