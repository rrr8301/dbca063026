#!/bin/bash
set -e

export RUSTFLAGS="-C debuginfo=0 -D warnings -A unfulfilled-lint-expectations"

# Run the test command matching the GitHub Actions workflow
cargo run -p ci -- test