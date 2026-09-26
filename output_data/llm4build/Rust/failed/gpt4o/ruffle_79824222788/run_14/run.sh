#!/bin/bash

# Activate Rust environment
source /home/testuser/.cargo/env

# Ensure cargo-nextest is installed with --locked
if ! command -v cargo-nextest &> /dev/null; then
    cargo install --locked cargo-nextest --root /home/testuser/.cargo
fi

# Set LIBCLANG_PATH to ensure bindgen can find libclang
export LIBCLANG_PATH=$(llvm-config --libdir)

# Install project dependencies
# (Assuming dependencies are managed via Cargo.toml)
cargo fetch

# Run tests
FEATURES="lzma,jpegxr,imgtests"
TEST_OPTS="--workspace --locked --no-fail-fast -j 4"
cargo nextest run --profile ci --cargo-profile ci ${TEST_OPTS} --features ${FEATURES}