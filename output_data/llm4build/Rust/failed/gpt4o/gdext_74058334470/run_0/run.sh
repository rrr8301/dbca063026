#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Patch Cargo.toml
.github/other/patch-prebuilt.sh nightly

# Install Rust toolchain
rustup toolchain install nightly --profile minimal --no-self-update
rustup default nightly

# Compile tests
cargo test $TEST_FEATURES --no-run

# Run tests
cargo test $TEST_FEATURES

# Run doctests with minimal feature set
cargo test --doc --no-default-features