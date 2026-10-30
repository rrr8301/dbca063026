#!/usr/bin/env bash

set -e

cd /app

echo "Running tests..."
cargo test --all --exclude niri-visual-tests -- --nocapture

echo "FINAL_STATUS = SUCCESS"
