#!/usr/bin/env bash
set -e

cd /app/crates

# Start gnome-keyring-daemon with secrets component
gnome-keyring-daemon --components=secrets --daemonize --unlock <<< 'foobar' || true

# Run tests
cargo test -- --skip scenario_tests::scenarios::tests
cargo test --jobs 1 scenario_tests::scenarios::tests

echo "FINAL_STATUS = SUCCESS"
