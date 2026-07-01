#!/usr/bin/env bash
set -e

cd /app

echo "Running tests with: cargo test --lib --bins --all"
cargo test --lib --bins --all

echo "FINAL_STATUS = SUCCESS"
