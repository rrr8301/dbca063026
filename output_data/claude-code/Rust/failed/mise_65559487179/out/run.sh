#!/usr/bin/env bash
set -e

export PATH="/app/target/debug:$PATH"
export CARGO_TERM_COLOR=always
export MISE_TRUSTED_CONFIG_PATHS=/app
export MISE_EXPERIMENTAL=1
export MISE_LOCKFILE=1
export RUST_BACKTRACE=1
export RUSTC_WRAPPER=sccache
export SCCACHE_DIR=$HOME/.cache/sccache

echo "=== Running unit tests ==="
cd /app
cargo test --all-features

echo "=== Running e2e tests ==="
cd /app
./e2e/run_all_tests

echo "=== sccache stats ==="
sccache --show-stats || true

echo "FINAL_STATUS = SUCCESS"
