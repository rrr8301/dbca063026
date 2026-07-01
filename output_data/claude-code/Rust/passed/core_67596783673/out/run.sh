#!/usr/bin/env bash
set -e

echo "Running Rust tests..."

echo "Installing nextest..."
cargo install --locked cargo-nextest

echo "Running tests with nextest..."
cargo nextest run --workspace --locked

echo "Running doc tests..."
cargo test --workspace --locked --doc

echo "Testing cargo vendor..."
cargo vendor

echo "FINAL_STATUS = SUCCESS"
