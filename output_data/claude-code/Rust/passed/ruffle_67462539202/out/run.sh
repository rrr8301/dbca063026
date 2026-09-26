#!/usr/bin/env bash

set -e

cd /app

echo "Running nextest..."
cargo nextest run --profile ci --cargo-profile ci ${TEST_OPTS} --features ${FEATURES}

echo "Running doctests..."
cargo test --doc --profile ci ${TEST_OPTS} --features ${FEATURES}

echo "FINAL_STATUS = SUCCESS"
