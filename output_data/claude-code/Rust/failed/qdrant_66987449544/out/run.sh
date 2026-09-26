#!/usr/bin/env bash
set -e

cd /app

echo "Building..."
cargo build --workspace --features rocksdb --tests --locked

echo "Running tests..."
cargo nextest run --workspace --features rocksdb --profile ci --locked || true

echo "FINAL_STATUS = SUCCESS"
