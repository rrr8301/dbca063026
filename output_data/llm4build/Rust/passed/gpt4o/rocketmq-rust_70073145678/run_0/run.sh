#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Set environment variables
export CARGO_TERM_COLOR=always
export RUST_BACKTRACE=full
export CI=true
export CARGO_PROFILE_DEV_DEBUG=false
export CARGO_PROFILE_TEST_DEBUG=false
export CARGO_PROFILE_DEV_OPT_LEVEL=1
export CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false
export CARGO_TARGET_DIR=target
export ROCKSDB_DISABLE_JEMALLOC=1

# Build the project
cargo build --workspace --all-features

# Run tests
cargo test --workspace --all-features