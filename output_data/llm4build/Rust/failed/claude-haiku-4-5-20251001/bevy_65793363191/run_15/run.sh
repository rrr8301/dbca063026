#!/bin/bash
set -e

export RUSTFLAGS="-C debuginfo=0 -D warnings -A unfulfilled-lint-expectations -A ambiguous-import-visibilities"

# Run the test command matching the GitHub Actions workflow
cargo run -p ci -- test