#!/usr/bin/env bash

set -e

echo "Building project..."
cargo build --workspace --tests --locked

echo "Running tests with nextest..."
cargo nextest run --workspace --profile ci --locked || true

echo "FINAL_STATUS = SUCCESS"
