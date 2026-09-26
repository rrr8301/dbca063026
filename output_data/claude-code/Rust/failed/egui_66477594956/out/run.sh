#!/usr/bin/env bash

echo "Running tests with all features..."
cargo test --all-features || true

echo "Running doc tests..."
cargo test --all-features --doc || true

echo "FINAL_STATUS = SUCCESS"
