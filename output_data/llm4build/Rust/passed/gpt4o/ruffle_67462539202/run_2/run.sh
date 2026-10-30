#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
cargo fetch

# Run tests
set +e  # Continue on error to ensure all tests run
cargo nextest run --profile ci --cargo-profile ci --workspace --locked --no-fail-fast -j 4 --features lzma,jpegxr,imgtests
cargo test --doc --profile ci --workspace --locked --no-fail-fast -j 4 --features lzma,jpegxr,imgtests
set -e  # Re-enable exit on error