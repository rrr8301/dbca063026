#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone . /app
cd /app

# Build the project
cargo build

# Check formatting
cargo fmt -- --check

# Run Clippy
cargo clippy --all-targets -- -Dclippy::all -D warnings

# Run tests
cargo test