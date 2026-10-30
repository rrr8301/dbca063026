#!/bin/bash

# Source Rust environment
source $HOME/.cargo/env

# Set environment variables
export RUST_LOG=debug
export RUST_BACKTRACE=full

# Run tests
cargo nextest run --workspace --profile ci --locked