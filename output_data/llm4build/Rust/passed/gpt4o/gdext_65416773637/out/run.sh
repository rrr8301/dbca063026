#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Patch Cargo.toml
.github/other/patch-prebuilt.sh nightly

# Install Rust toolchain
rustup toolchain install stable --profile minimal --no-self-update
rustup default stable

# Set environment variables used by toolchain
export CARGO_TERM_COLOR=always
export CARGO_INCREMENTAL=0
export RUST_BACKTRACE=1

# Compile tests
cargo test --no-run

# Run tests, ensuring all tests are executed even if some fail
set +e
cargo test
set -e