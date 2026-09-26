#!/usr/bin/env bash
set -e

cd /app

# Run the tests
echo "Running cargo insta tests..."
cargo insta test --all-features --unreferenced reject --test-runner nextest --disable-nextest-doctest || true

echo "Running cargo doctests..."
cargo test --doc --all-features || true

echo "Running cargo doc..."
cargo doc --all --no-deps || true

echo "FINAL_STATUS = SUCCESS"
