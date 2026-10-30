#!/usr/bin/env bash
set -e

cd /app

echo "Running Bevy CI tests..."
cargo run -p ci -- test

echo "FINAL_STATUS = SUCCESS"
