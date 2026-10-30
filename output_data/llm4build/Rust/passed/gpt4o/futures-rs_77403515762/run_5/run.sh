#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Change to the workspace directory
cd /workspace

# Run tests
cargo test --workspace --all-features $DOCTEST_XCOMPILE
cargo test --workspace --all-features --release $DOCTEST_XCOMPILE