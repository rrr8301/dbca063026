#!/usr/bin/env bash
set -e

export RUST_LOG=debug
export RUST_BACKTRACE=full

echo "Running cargo nextest..."
cargo nextest run --workspace --profile ci --locked || TEST_RESULT=$?

echo "Running doctests..."
cargo test --doc --workspace --locked || DOCTEST_RESULT=$?

if [ -z "$TEST_RESULT" ] && [ -z "$DOCTEST_RESULT" ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
fi
