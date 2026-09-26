#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Build tests
cargo test --no-run --all --exclude niri-visual-tests

# Run tests
cargo test --all --exclude niri-visual-tests -- --nocapture