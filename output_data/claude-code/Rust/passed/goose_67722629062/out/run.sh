#!/usr/bin/env bash

set -e

cd /app/crates

echo "Starting gnome-keyring daemon..."
gnome-keyring-daemon --components=secrets --daemonize --unlock <<< 'foobar'

echo "Running cargo tests..."
export CARGO_INCREMENTAL=0
export RUST_MIN_STACK=8388608

echo "Running tests (skipping scenario tests)..."
cargo test -- --skip scenario_tests::scenarios::tests

echo "Running scenario tests with 1 job..."
cargo test --jobs 1 scenario_tests::scenarios::tests

echo "FINAL_STATUS = SUCCESS"
