#!/bin/bash

# Activate Rust environment
source /home/testuser/.cargo/env

# Install cargo nextest as the non-root user
cargo install cargo-nextest --root /home/testuser/.cargo

# Install project dependencies
# (Assuming dependencies are managed via Cargo.toml)
cargo fetch

# Run tests
FEATURES="lzma,jpegxr,imgtests"
TEST_OPTS="--workspace --locked --no-fail-fast -j 4"
cargo nextest run --profile ci --cargo-profile ci ${TEST_OPTS} --features ${FEATURES}